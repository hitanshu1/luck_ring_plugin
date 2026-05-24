import Foundation
import CoreBluetooth
import BluetoothLibrary

/// Bridges Luck Ring plugin to BluetoothLibrary framework.
/// iOS uses CBPeripheral (no MAC in public API); SearchPeripheral provides macAddress for matching.
class LuckRingSdkBridge: NSObject {

    static let shared = LuckRingSdkBridge()

    private var discoveredPeripherals: [String: SearchPeripheral] = [:]
    private var scanCallback: (([[String: Any]]) -> Void)?
    private var connectCompletion: ((Bool) -> Void)?
    private var healthDataCompletion: (([String: Any]) -> Void)?
    private var healthCollector: [String: Any] = [:]
    private var scanWorkItem: DispatchWorkItem?
    private var healthTimeoutWorkItem: DispatchWorkItem?
    /// Fires a short grace period after the first valid BP reading lands so
    /// any in-flight HR / SpO2 packets can still be collected before we
    /// resolve the completion. See `parseBPData` / `scheduleEarlyHealthFinish`.
    private var healthBpGraceWorkItem: DispatchWorkItem?
    /// Grace window after BP arrives, before completing the call.
    private let healthBpGraceSecs: Double = 2.0
    /// Absolute hard cap on how long we'll wait for BP, regardless of
    /// caller's `timeoutMs` — prevents the call from hanging forever if the
    /// ring keeps emitting in-progress markers but never finishes.
    private let healthBpAbsoluteMaxSecs: Double = 180.0
    /// How far to push the deadline each time BP is still in progress at
    /// the previous deadline.
    private let healthBpExtendStepSecs: Double = 30.0
    /// True once any 0x12 (REAL_BP) packet has been observed — including
    /// the device's in-progress 0/0 markers. Tells us the BP measurement
    /// cycle is actively running on the ring.
    private var healthBpInProgress: Bool = false
    /// Wall-clock deadline (`Date`) past which we stop extending the BP wait.
    private var healthBpAbsoluteDeadline: Date?
    /// How long Phase 1 (HR + SpO2) runs before we stop those sensors and
    /// switch the ring over to a BP-only measurement. Many K6 firmware
    /// builds drive HR / SpO2 / BP off the *same* PPG channel and the BP
    /// cycle is silently starved if HR streaming is concurrently running.
    private let healthHrPhaseSecs: Double = 10.0
    /// Work item that runs the Phase 1 → Phase 2 (BP-only) handoff.
    private var healthBpPhaseWorkItem: DispatchWorkItem?
    /// Periodic re-issue of `SyncBloodPressureCmd(status=1)` while we're
    /// waiting for BP — some firmwares need the command nudged multiple
    /// times before they actually start the cycle.
    private var healthBpNudgeWorkItem: DispatchWorkItem?
    /// Cadence at which we re-send `SyncBloodPressureCmd(status=1)`.
    private let healthBpNudgeIntervalSecs: Double = 20.0

    /// Demographic profile pushed to the ring before a BP measurement. The
    /// K6 firmware uses these as inputs to its PPG-based BP calculation —
    /// without them many builds simply refuse to start the BP cycle and
    /// never produce a 0x12 packet. Defaults are deliberately generic;
    /// callers should override via `setUserInfo` if real demographics are
    /// available.
    private var userSex: UInt8 = 0      // 0 = male, 1 = female
    private var userAge: UInt8 = 30
    private var userHeightCm: UInt8 = 170
    private var userWeightKg: UInt8 = 70

    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onScanPeripherals(_:)),
            name: NSNotification.Name(ScanPeripheralsNoticeKey),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onReceiveData(_:)),
            name: NSNotification.Name(CEProductK6ReceiveDataNoticeKey),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onStatusChange(_:)),
            name: NSNotification.Name(ProductStatusChangeNoticeKey),
            object: nil
        )
    }

    func initSdk() {
        // iOS SDK auto-initializes via CEProductK6.shareInstance()
        _ = CEProductK6.shareInstance()
    }

    func startScan(timeoutMs: Int, onDevices: @escaping ([[String: Any]]) -> Void) {
        scanCallback = onDevices
        discoveredPeripherals.removeAll()
        CEProductK6.shareInstance().startScan()
        scanWorkItem?.cancel()
        scanWorkItem = DispatchWorkItem { [weak self] in
            CEProductK6.shareInstance().stopScan()
            self?.emitScanResults()
            self?.scanCallback = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(timeoutMs) / 1000, execute: scanWorkItem!)
    }

    func stopScan() {
        scanWorkItem?.cancel()
        scanWorkItem = nil
        CEProductK6.shareInstance().stopScan()
        scanCallback = nil
    }

    func connect(address: String, completion: @escaping (Bool) -> Void) {
        let sp = discoveredPeripherals[address]
            ?? discoveredPeripherals.values.first { ($0.macAddress() ?? "").uppercased() == address.uppercased() }
        guard let peripheral = sp?.peripheral else {
            completion(false)
            return
        }
        connectCompletion = completion
        CEProductK6.shareInstance().connect(peripheral)
    }

    func disconnect() {
        CEProductK6.shareInstance().releaseBind()
    }

    func isConnected() -> Bool {
        let status = CEProductK6.shareInstance().status
        return status == .completed || status == .connected
    }

    /// Updates the demographic profile pushed to the ring before BP
    /// measurements. Values outside the SDK's `uint8` range are clamped.
    func setUserInfo(sex: Int?, age: Int?, heightCm: Int?, weightKg: Int?) {
        if let s = sex { userSex = UInt8(max(0, min(1, s))) }
        if let a = age { userAge = UInt8(max(1, min(120, a))) }
        if let h = heightCm { userHeightCm = UInt8(max(80, min(230, h))) }
        if let w = weightKg { userWeightKg = UInt8(max(20, min(200, w))) }
        // Push immediately if we're already connected so the ring picks up
        // the new profile without waiting for the next health call.
        if isConnected(), let sdk = CEProductK6.shareInstance() {
            sendCmdLogged(sdk, makeUserInfoCmd(),
                label: "SyncUserInfoCmd(sex=\(userSex) age=\(userAge) "
                     + "h=\(userHeightCm) w=\(userWeightKg)) [from setUserInfo]")
        }
    }

    private func makeUserInfoCmd() -> CE_SyncUserInfoCmd {
        let cmd = CE_SyncUserInfoCmd()
        cmd.userId = 1
        cmd.sex = userSex
        cmd.age = userAge
        cmd.height = userHeightCm
        cmd.weight = userWeightKg
        cmd.lrHand = 1
        return cmd
    }

    /// Two-phase sequential health collection — required because most K6
    /// firmware builds (incl. `753.0.1.8.0`) drive HR / SpO2 / BP off the
    /// *same* PPG channel and the BP measurement cycle is silently starved
    /// if HR streaming is running concurrently.
    ///
    /// Phase 1 (`healthHrPhaseSecs` seconds): HR + SpO2 + battery + device
    /// info. Quick — values are pushed back within a few seconds.
    ///
    /// Phase 2 (rest of the wait): stop HR + SpO2, then start BP *alone*.
    /// We also periodically re-issue `SyncBloodPressureCmd(status=1)` every
    /// `healthBpNudgeIntervalSecs` because some K6 builds need the command
    /// nudged multiple times before they actually start the cycle.
    ///
    /// Completion:
    /// - Resolves early (`bp-received`) on the first valid 0x12 BP packet
    ///   plus a short grace window.
    /// - Resolves at the soft deadline (`timeout`) once Phase 2 elapses.
    /// - If 0x12 / `0x34` / `0x35` / `0xFA` markers show BP is still being
    ///   measured at the soft deadline, the wait extends in 30s chunks up
    ///   to `healthBpAbsoluteMaxSecs` (180s) total.
    func getHealthData(timeoutMs: Int, completion: @escaping ([String: Any]) -> Void) {
        NSLog("[LuckRing] ===== getHealthData START timeoutMs=%d connected=%@ =====",
              timeoutMs, isConnected() ? "true" : "false")

        guard isConnected() else {
            NSLog("[LuckRing] getHealthData aborted: device not connected")
            completion(["errorMessage": "Device not connected"])
            return
        }

        // If a previous call is still pending, cancel its timers so we don't
        // double-fire or lose this completion.
        healthTimeoutWorkItem?.cancel()
        healthTimeoutWorkItem = nil
        healthBpGraceWorkItem?.cancel()
        healthBpGraceWorkItem = nil
        healthBpPhaseWorkItem?.cancel()
        healthBpPhaseWorkItem = nil
        healthBpNudgeWorkItem?.cancel()
        healthBpNudgeWorkItem = nil

        healthDataCompletion = completion
        // Reset per-call measurement lists so callers get fresh data
        // (battery / deviceInfo from connect time can stay).
        healthCollector["heartRate"] = [[String: Any]]()
        healthCollector["bloodOxygen"] = [[String: Any]]()
        healthCollector["bloodPressure"] = [[String: Any]]()
        healthCollector["sleep"] = [[String: Any]]()
        healthCollector["sport"] = [[String: Any]]()
        healthBpInProgress = false

        let sdk = CEProductK6.shareInstance()!

        // ---- Phase 1: HR + SpO2 + housekeeping ----
        // Open sensor data switch (device only uploads health data when this is on)
        let sensorCmd = CE_SensorCmd()
        sensorCmd.onoff = 1
        sendCmdLogged(sdk, sensorCmd, label: "SensorCmd(onoff=1)")

        // Push user demographics — REQUIRED for BP on most K6 firmware
        // builds. The ring uses sex/age/height/weight as inputs to its
        // PPG-based BP calculation and silently skips the BP cycle (never
        // emits a 0x12 packet) if user info hasn't been set.
        sendCmdLogged(sdk, makeUserInfoCmd(),
            label: "SyncUserInfoCmd(sex=\(userSex) age=\(userAge) "
                 + "h=\(userHeightCm) w=\(userWeightKg))")

        // Request battery + device info (quick, lightweight)
        sendCmdLogged(sdk, CE_RequestBatteryCmd(), label: "RequestBatteryCmd")
        sendCmdLogged(sdk, CE_RequestDevInfoCmd(), label: "RequestDevInfoCmd")

        // Request historical blood pressure (if device has stored data)
        sendCmdLogged(sdk, CE_RequestBloodPresureCmd(),
            label: "RequestBloodPresureCmd")

        // Phase 1 sensor stream: HR + SpO2 only. BP is deliberately
        // delayed until Phase 2 so the PPG channel isn't contested.
        let heartO2 = CE_SyncHeartO2Cmd()
        heartO2.status = 1
        sendCmdLogged(sdk, heartO2, label: "SyncHeartO2Cmd(status=1)")

        let hr = CE_SyncHeartRateCmd()
        hr.status = 1
        sendCmdLogged(sdk, hr, label: "SyncHeartRateCmd(status=1)")

        let waitSecs = max(Double(timeoutMs) / 1000.0, 5.0)
        let absoluteSecs = max(waitSecs, healthBpAbsoluteMaxSecs)
        healthBpAbsoluteDeadline = Date(timeIntervalSinceNow: absoluteSecs)

        NSLog("[LuckRing] Phase 1 (HR+SpO2) running %.1fs, then handing "
            + "off to Phase 2 (BP-only). soft wait=%.1fs, absolute cap=%.1fs",
            healthHrPhaseSecs, waitSecs, absoluteSecs)

        // Schedule the Phase 2 handoff.
        let phase2Delay = min(healthHrPhaseSecs, waitSecs * 0.2)
        let phase2 = DispatchWorkItem { [weak self] in
            self?.startBpPhase()
        }
        healthBpPhaseWorkItem = phase2
        DispatchQueue.main.asyncAfter(deadline: .now() + phase2Delay,
                                       execute: phase2)

        // Soft timeout — fires after the *full* requested timeout. The
        // handler then decides whether to finish or extend based on BP
        // activity, exactly as before.
        scheduleHealthTimeout(after: waitSecs)
    }

    /// Phase 2: stop HR/SpO2, then start BP alone. Also primes the BP nudge
    /// timer that re-sends `SyncBloodPressureCmd(status=1)` every
    /// `healthBpNudgeIntervalSecs` until a 0x12 reading arrives or we
    /// finish.
    private func startBpPhase() {
        guard healthDataCompletion != nil,
              let sdk = CEProductK6.shareInstance() else { return }

        NSLog("[LuckRing] ===== Phase 2: stopping HR/SpO2, starting BP alone =====")

        // Stop HR + SpO2 so the PPG channel is free for BP.
        let stopHrO2 = CE_SyncHeartO2Cmd()
        stopHrO2.status = 0
        sendCmdLogged(sdk, stopHrO2,
            label: "SyncHeartO2Cmd(status=0) [phase2: stop for BP]")

        let stopHr = CE_SyncHeartRateCmd()
        stopHr.status = 0
        sendCmdLogged(sdk, stopHr,
            label: "SyncHeartRateCmd(status=0) [phase2: stop for BP]")

        // Send BP after a short delay so the ring has time to release the
        // PPG channel before we ask it to start a fresh cycle.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.issueBpCommand(reason: "phase2-initial")
            self?.scheduleBpNudge()
        }
    }

    /// Issues `SyncBloodPressureCmd(status=1)`. Called both from Phase 2
    /// startup and from the periodic nudge timer.
    private func issueBpCommand(reason: String) {
        guard healthDataCompletion != nil,
              let sdk = CEProductK6.shareInstance() else { return }
        let bp = CE_SyncBloodPressureCmd()
        bp.status = 1
        sendCmdLogged(sdk, bp,
            label: "SyncBloodPressureCmd(status=1) [\(reason)]")
    }

    /// Re-issues the BP command on a recurring schedule until BP arrives or
    /// the session ends. Cleared by `finishHealthCollection`.
    private func scheduleBpNudge() {
        healthBpNudgeWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self, self.healthDataCompletion != nil else { return }

            let bpCount = (self.healthCollector["bloodPressure"] as? [[String: Any]])?.count ?? 0
            if bpCount > 0 {
                NSLog("[LuckRing] BP already collected, skipping nudge")
                return
            }
            self.issueBpCommand(reason: "nudge")
            self.scheduleBpNudge()
        }
        healthBpNudgeWorkItem = work
        DispatchQueue.main.asyncAfter(
            deadline: .now() + healthBpNudgeIntervalSecs,
            execute: work)
    }

    /// Schedules / reschedules the soft timeout. Used both for the initial
    /// `timeoutMs` deadline and for subsequent extend-while-BP-in-progress
    /// chunks.
    private func scheduleHealthTimeout(after secs: Double) {
        healthTimeoutWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.onHealthTimeoutFired()
        }
        healthTimeoutWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + secs, execute: work)
    }

    /// Soft-timeout handler. Decides whether to finalize the call or extend
    /// the wait because BP is still actively measuring on the ring.
    private func onHealthTimeoutFired() {
        // Already finished (grace path beat us to it)?
        guard healthDataCompletion != nil else { return }

        let bpCount = (healthCollector["bloodPressure"] as? [[String: Any]])?.count ?? 0

        // Valid BP already collected → arm grace (if not already) so we
        // include any HR/SpO2 stragglers, then exit.
        if bpCount > 0 {
            scheduleEarlyHealthFinish()
            return
        }

        let now = Date()
        let absoluteDeadline = healthBpAbsoluteDeadline ?? now

        // BP still actively measuring AND we have headroom → extend.
        if healthBpInProgress && now < absoluteDeadline {
            let remaining = absoluteDeadline.timeIntervalSince(now)
            let step = min(healthBpExtendStepSecs, remaining)
            NSLog("[LuckRing] BP still in progress on ring, extending wait "
                + "by %.1fs (%.1fs remaining of absolute cap)",
                step, remaining)
            scheduleHealthTimeout(after: step)
            return
        }

        // Either BP never started streaming, or we hit the absolute cap.
        let reason = healthBpInProgress
            ? "bp-absolute-cap"
            : "timeout-no-bp-activity"
        finishHealthCollection(reason: reason)
    }

    /// Called whenever a packet that indicates the ring is actively running
    /// a BP / PPG cycle is seen — either a real 0x12 packet or one of the
    /// undocumented BP-cycle markers (0x2A / 0x2F / 0x34 / 0x35 / 0xFA).
    /// Tells the timeout handler that BP is still being measured so we
    /// shouldn't give up yet.
    func markBpInProgress() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.healthDataCompletion != nil else { return }
            if !self.healthBpInProgress {
                NSLog("[LuckRing] BP measurement cycle active on ring "
                    + "(first BP-related packet observed)")
                self.healthBpInProgress = true
            }
        }
    }

    /// Called from `parseBPData` the moment the first valid BP reading is
    /// appended. Schedules `finishHealthCollection` after a short grace
    /// window so HR/SpO2 stragglers can still be collected.
    private func scheduleEarlyHealthFinish() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // No active call, or grace already armed — nothing to do.
            guard self.healthDataCompletion != nil,
                  self.healthBpGraceWorkItem == nil else { return }

            NSLog("[LuckRing] BP received — finalizing in %.1fs",
                  self.healthBpGraceSecs)

            let grace = DispatchWorkItem { [weak self] in
                self?.finishHealthCollection(reason: "bp-received")
            }
            self.healthBpGraceWorkItem = grace
            DispatchQueue.main.asyncAfter(
                deadline: .now() + self.healthBpGraceSecs,
                execute: grace
            )
        }
    }

    /// Idempotent teardown: stops real-time sensors, cancels pending timers,
    /// and delivers `healthCollector` to the pending completion (if any).
    private func finishHealthCollection(reason: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let comp = self.healthDataCompletion else { return }

            self.healthTimeoutWorkItem?.cancel()
            self.healthTimeoutWorkItem = nil
            self.healthBpGraceWorkItem?.cancel()
            self.healthBpGraceWorkItem = nil
            self.healthBpPhaseWorkItem?.cancel()
            self.healthBpPhaseWorkItem = nil
            self.healthBpNudgeWorkItem?.cancel()
            self.healthBpNudgeWorkItem = nil
            self.healthBpAbsoluteDeadline = nil
            self.healthBpInProgress = false

            if let sdk = CEProductK6.shareInstance() {
                let stopHrO2 = CE_SyncHeartO2Cmd()
                stopHrO2.status = 0
                self.sendCmdLogged(sdk, stopHrO2, label: "SyncHeartO2Cmd(status=0) [stop]")

                let stopHr = CE_SyncHeartRateCmd()
                stopHr.status = 0
                self.sendCmdLogged(sdk, stopHr, label: "SyncHeartRateCmd(status=0) [stop]")

                let stopBp = CE_SyncBloodPressureCmd()
                stopBp.status = 0
                self.sendCmdLogged(sdk, stopBp, label: "SyncBloodPressureCmd(status=0) [stop]")
            }

            let bpCount = (self.healthCollector["bloodPressure"] as? [[String: Any]])?.count ?? 0
            let hrCount = (self.healthCollector["heartRate"] as? [[String: Any]])?.count ?? 0
            let o2Count = (self.healthCollector["bloodOxygen"] as? [[String: Any]])?.count ?? 0
            NSLog("[LuckRing] ===== getHealthData DONE reason=%@ hr=%d o2=%d bp=%d =====",
                  reason, hrCount, o2Count, bpCount)
            NSLog("[LuckRing] final collected payload=%@",
                  self.healthCollector as NSDictionary)

            self.healthDataCompletion = nil
            comp(self.healthCollector)
        }
    }

    @objc private func onScanPeripherals(_ noti: Notification) {
        guard let arr = noti.object as? [SearchPeripheral] else { return }
        for sp in arr {
            if let mac = sp.macAddress(), !mac.isEmpty {
                discoveredPeripherals[mac] = sp
            }
            if let periph = sp.peripheral {
                discoveredPeripherals[periph.identifier.uuidString] = sp
            }
        }
        emitScanResults()
    }

    private func peripheralName(_ sp: SearchPeripheral) -> String {
        if let n = sp.name(), !n.isEmpty { return n }
        if let pName = sp.peripheral?.name, !pName.isEmpty { return pName }
        return "Unknown"
    }

    private func emitScanResults() {
        var seen = Set<String>()
        var list = [[String: String]]()
        for sp in discoveredPeripherals.values {
            let mac = sp.macAddress() ?? ""
            let address = mac.isEmpty
                ? (sp.peripheral?.identifier.uuidString ?? "")
                : mac
            if address.isEmpty || seen.contains(address) { continue }
            seen.insert(address)

            let devId = sp.deviceID() ?? ""

            list.append([
                "name": peripheralName(sp),
                "address": address,
                "deviceId": devId.isEmpty
                    ? (sp.peripheral?.identifier.uuidString ?? "")
                    : devId
            ])
        }
        scanCallback?(list)
    }

    @objc private func onStatusChange(_ noti: Notification) {
        guard let status = noti.object as? NSNumber else {
            NSLog("[LuckRing] onStatusChange: malformed notification object=%@",
                  String(describing: noti.object))
            return
        }
        let s = status.intValue
        NSLog("[LuckRing] >>>>> status change=%d (%@)", s, productStatusName(s))
        if s == 6 { // ProductStatus_completed — pairing done, can communicate
            NSLog("[LuckRing] Device connected & paired, requesting all info")
            healthCollector = [:]
            if let sdk = CEProductK6.shareInstance() {
                sendCmdLogged(sdk, CE_RequestAllInfoCmd(),
                    label: "RequestAllInfoCmd [on-connect]")
            }
            connectCompletion?(true)
            connectCompletion = nil
        } else if s == 4 { // ProductStatus_disconnected
            connectCompletion?(false)
            connectCompletion = nil
        }
    }

    private func productStatusName(_ s: Int) -> String {
        switch s {
        case 0: return "unknown"
        case 1: return "powerOff"
        case 2: return "scanning"
        case 3: return "connecting"
        case 4: return "disconnected"
        case 5: return "connected"
        case 6: return "completed"
        default: return "status_\(s)"
        }
    }

    private func dictFromAny(_ value: Any?) -> [String: Any] {
        if let d = value as? [String: Any] { return d }
        if let ns = value as? NSDictionary {
            var result = [String: Any]()
            for (k, v) in ns { if let key = k as? String { result[key] = v } }
            return result
        }
        return [:]
    }

    /// Coerce an arbitrary value (NSArray, NSDictionary, single dict, …) into
    /// `[[String: Any]]`. SDK payloads are bridged from Objective-C and
    /// sometimes don't cast cleanly with `as? [[String: Any]]` when nested.
    private func arrayFromAny(_ value: Any?) -> [[String: Any]] {
        guard let value = value else { return [] }
        if let arr = value as? [[String: Any]] { return arr }
        if let arr = value as? [Any] {
            return arr.compactMap { item -> [String: Any]? in
                let d = dictFromAny(item)
                return d.isEmpty ? nil : d
            }
        }
        if let ns = value as? NSArray {
            var result = [[String: Any]]()
            for item in ns {
                let d = dictFromAny(item)
                if !d.isEmpty { result.append(d) }
            }
            return result
        }
        // Single dict shaped payload (some devices skip the array wrapper
        // when only one reading is emitted).
        let single = dictFromAny(value)
        return single.isEmpty ? [] : [single]
    }

    private func intFromAny(_ value: Any?) -> Int? {
        if let v = value as? Int { return v }
        if let v = value as? NSNumber { return v.intValue }
        if let v = value as? String, let n = Int(v) { return n }
        return nil
    }

    @objc private func onReceiveData(_ noti: Notification) {
        // SDK docs: data arrives via userInfo with keys DataType (NSNumber) and Data (NSDictionary)
        let ui = noti.userInfo

        guard let typeNum = ui?["DataType"] as? NSNumber else {
            NSLog("[LuckRing] >>>>> onReceiveData: NO DataType in userInfo. "
                + "userInfo=%@, object=%@",
                String(describing: ui), String(describing: noti.object))
            return
        }

        let type = typeNum.intValue
        let d = dictFromAny(ui?["Data"])

        // Full verbose dump of every incoming packet — type code, friendly
        // name, key list, full payload, and a hex dump for any embedded
        // UnknownBody blob. Captured here so the user can copy/paste a
        // complete trace when debugging BP / sensor behaviour.
        NSLog("[LuckRing] <<<<< RECV type=0x%02X (%@) keys=%@",
              type, dataTypeName(type), Array(d.keys))
        NSLog("[LuckRing]       full payload=%@", d as NSDictionary)
        if let body = d["UnknownBody"] as? NSData {
            NSLog("[LuckRing]       UnknownBody hex (%d bytes)=%@",
                  body.length, hexDump(body))
        }

        switch type {
        case 0x07, 0x08, 0x11, 0x18:
            // DATA_TYPE_REAL_HEART, HISTORY_HEART, EXERCISE_HEART, REAL_HR
            parseHeartData(d)
        case 0x14, 40:
            // DATA_TYPE_REAL_O2, DATA_TYPE_HISTORY_O2
            parseO2Data(d)
        case 0x12:
            // DATA_TYPE_REAL_BP — any packet (even 0/0 in-progress markers)
            // means the BP measurement cycle is running on the ring; tell
            // the timeout handler so it extends the wait instead of giving
            // up at the initial deadline.
            markBpInProgress()
            parseBPData(d)
        case 0x06:
            // DATA_TYPE_SLEEP
            parseSleepData(d)
        case 0x04, 0x05, 0x0a:
            // DATA_TYPE_REAL_SPORT, HISTORY_SPORT, MIX_SPORT
            parseSportData(d)
        case 0x03:
            // DATA_TYPE_BATTERY_INFO
            if let cap = intFromAny(d["battery_capacity"])
                ?? intFromAny(d["batteryCapacity"])
                ?? intFromAny(d["battery"]) {
                healthCollector["batteryLevel"] = cap
            } else {
                for (_, v) in d {
                    if let cap = intFromAny(v), cap >= 0 && cap <= 100 {
                        healthCollector["batteryLevel"] = cap
                        break
                    }
                }
            }
        case 0x02:
            // DATA_TYPE_DEVINFO
            healthCollector["deviceInfo"] = [
                "macAddress": (d["macAddr"] as? String) ?? (d["mac"] as? String) ?? "",
                "version": (d["version"] as? String) ?? (d["firmwareVersion"] as? String) ?? "",
                "deviceId": (d["ID"] as? String) ?? (d["id"] as? String) ?? ""
            ]
        case 0x2A, 0x2F, 0x34, 0x35, 0xFA:
            // Undocumented packet types observed during a BP measurement
            // cycle (raw PPG / sensor frames + measurement-state markers).
            // Full payload already logged above; here we just mark BP as
            // actively measuring so the timeout extender stays armed.
            markBpInProgress()
        default:
            // No further parsing — the full payload was already dumped above.
            break
        }
    }

    /// Maps a `K6_DataFuncType` byte to its enum name from `FuncType.h`,
    /// or `"UNDOCUMENTED"` for codes outside the documented range. Makes
    /// log lines greppable without cross-referencing the SDK header.
    private func dataTypeName(_ type: Int) -> String {
        switch type {
        case 0x02: return "DEVINFO"
        case 0x03: return "BATTERY_INFO"
        case 0x04: return "REAL_SPORT"
        case 0x05: return "HISTORY_SPORT"
        case 0x06: return "SLEEP"
        case 0x07: return "REAL_HEART"
        case 0x08: return "HISTORY_HEART"
        case 0x09: return "DEV_SYNC"
        case 0x0a: return "MIX_SPORT"
        case 0x0b: return "FIND_PHONE_OR_DEVICE"
        case 0x0c: return "BLE_PAIR_STATUS"
        case 0x0d: return "USER_CHANGE"
        case 0x0e: return "MUSIC_CONTROL"
        case 0x0f: return "CALL_CONTROL_TO_APP"
        case 0x10: return "GSENSOR_TEST"
        case 0x11: return "EXERCISE_HEART"
        case 0x12: return "REAL_BP"
        case 0x13: return "REAL_ECG"
        case 0x14: return "REAL_O2"
        case 0x15: return "HR_CONTROL"
        case 0x16: return "FUNCTION_CONTROL"
        case 0x17: return "HARDWARE_INFO"
        case 0x18: return "REAL_HR"
        case 0x19: return "BTEDR_ADDR"
        case 26:   return "QR_CODE_INFO"
        case 40:   return "HISTORY_O2"
        default:   return "UNDOCUMENTED"
        }
    }

    /// Pretty-prints `NSData` as space-separated hex bytes, 16 per line.
    /// Use this for any blob you want to share in a bug report — keeps
    /// the output greppable and copy-pasteable, unlike NSData's default
    /// `{length=… bytes=0x…}` representation that truncates after 64 bytes.
    private func hexDump(_ data: NSData) -> String {
        let total = data.length
        guard total > 0 else { return "" }
        let bytes = data.bytes.assumingMemoryBound(to: UInt8.self)
        var lines: [String] = []
        var i = 0
        while i < total {
            let end = min(i + 16, total)
            var line = String(format: "%04x: ", i)
            for j in i..<end {
                line += String(format: "%02x ", bytes[j])
            }
            lines.append(line)
            i = end
        }
        return "\n" + lines.joined(separator: "\n")
    }

    /// Thin wrapper around `sdk.sendCmd(toDevice:complete:)` that logs the
    /// outbound command + the SDK's completion error (if any). Lets you
    /// correlate each request with the device's reply, and surfaces silent
    /// rejections — e.g. a BP command that the firmware discards — that
    /// would otherwise be invisible.
    private func sendCmdLogged(_ sdk: CEProductK6, _ cmd: CE_Cmd, label: String) {
        NSLog("[LuckRing] >>>>> SEND %@ cmd=%@", label, cmd)
        sdk.sendCmd(toDevice: cmd) { error in
            if let err = error {
                NSLog("[LuckRing]       SEND %@ ERROR: %@", label, err as NSError)
            }
        }
    }

    private func parseHeartData(_ data: [String: Any]) {
        var list = healthCollector["heartRate"] as? [[String: Any]] ?? []
        var infos = arrayFromAny(data["heartInfos"])
        if infos.isEmpty { infos = arrayFromAny(data["heartRateInfos"]) }
        if infos.isEmpty { infos = arrayFromAny(data["data"]) }
        for info in infos {
            let val = intFromAny(info["heartNum"])
                ?? intFromAny(info["heartRate"])
                ?? intFromAny(info["value"]) ?? 0
            if val <= 0 { continue }
            var entry: [String: Any] = ["value": val]
            if let time = intFromAny(info["time"]) {
                entry["timestamp"] = formatTimestamp(Int64(time))
            }
            list.append(entry)
        }
        healthCollector["heartRate"] = list
    }

    private func parseO2Data(_ data: [String: Any]) {
        var list = healthCollector["bloodOxygen"] as? [[String: Any]] ?? []
        var arr = arrayFromAny(data["data"])
        if arr.isEmpty { arr = arrayFromAny(data["o2Infos"]) }
        for item in arr {
            let val = intFromAny(item["O2"])
                ?? intFromAny(item["o2"])
                ?? intFromAny(item["value"]) ?? 0
            if val <= 0 { continue }
            var entry: [String: Any] = ["value": val]
            if let time = intFromAny(item["time"]) {
                entry["timestamp"] = formatTimestamp(Int64(time))
            }
            list.append(entry)
        }
        healthCollector["bloodOxygen"] = list
    }

    /// DATA_TYPE_REAL_BP payload shape per SDK docs:
    ///   { remainItemCount, curItemCount, data: [ { time, systolic, diastolic } ] }
    ///
    /// In practice the BluetoothLibrary framework can also push a single BP
    /// reading directly on `data` (no array wrapper) when the K6 ring
    /// finishes a measurement cycle, so we accept both shapes and any
    /// alternative key spellings we've seen in the wild.
    private func parseBPData(_ data: [String: Any]) {
        var list = healthCollector["bloodPressure"] as? [[String: Any]] ?? []

        // Collect every candidate item shape we know about.
        var items = arrayFromAny(data["data"])
        if items.isEmpty { items = arrayFromAny(data["bpInfos"]) }
        if items.isEmpty { items = arrayFromAny(data["bloodPressureInfos"]) }
        if items.isEmpty { items = arrayFromAny(data["items"]) }

        // Fallback: BP info inlined on the top-level dict (single reading).
        let topSys = intFromAny(data["systolic"]) ?? intFromAny(data["highPressure"])
        let topDia = intFromAny(data["diastolic"]) ?? intFromAny(data["lowPressure"])
        if items.isEmpty, topSys != nil || topDia != nil {
            var single: [String: Any] = [:]
            if let s = topSys { single["systolic"] = s }
            if let d = topDia { single["diastolic"] = d }
            if let t = intFromAny(data["time"]) { single["time"] = t }
            items = [single]
        }

        NSLog("[LuckRing] BP payload: keys=%@ items=%d", Array(data.keys), items.count)

        var added = 0
        for item in items {
            let sys = intFromAny(item["systolic"])
                ?? intFromAny(item["highPressure"])
                ?? intFromAny(item["bp_sbp"])
                ?? intFromAny(item["sbp"]) ?? 0
            let dia = intFromAny(item["diastolic"])
                ?? intFromAny(item["lowPressure"])
                ?? intFromAny(item["bp_dbp"])
                ?? intFromAny(item["dbp"]) ?? 0
            // Drop "end-of-stream" / "in-progress" markers — the device sends
            // 0/0 readings while a measurement is still running.
            if sys <= 0 && dia <= 0 { continue }
            var entry: [String: Any] = ["systolic": sys, "diastolic": dia]
            if let time = intFromAny(item["time"]) {
                entry["timestamp"] = formatTimestamp(Int64(time))
            }
            list.append(entry)
            added += 1
        }

        if added > 0 {
            NSLog("[LuckRing] BP added=%d total=%d", added, list.count)
        }
        healthCollector["bloodPressure"] = list

        // First valid BP reading? Trigger the early-finish grace window so
        // `getHealthData` resolves without waiting the full timeout.
        if added > 0 {
            scheduleEarlyHealthFinish()
        }
    }

    private func parseSleepData(_ data: [String: Any]) {
        var list = healthCollector["sleep"] as? [[String: Any]] ?? []
        var infos = arrayFromAny(data["sleepInfos"])
        if infos.isEmpty { infos = arrayFromAny(data["data"]) }
        for info in infos {
            let stage = intFromAny(info["SleepType"])
                ?? intFromAny(info["sleepType"])
                ?? intFromAny(info["stage"]) ?? 0
            var entry: [String: Any] = ["stage": stage]
            let time = intFromAny(info["SleepStartTime"])
                ?? intFromAny(info["sleepStartTime"])
                ?? intFromAny(info["time"])
            if let time = time {
                entry["startTime"] = formatTimestamp(Int64(time))
            }
            list.append(entry)
        }
        healthCollector["sleep"] = list
    }

    private func parseSportData(_ data: [String: Any]) {
        var list = healthCollector["sport"] as? [[String: Any]] ?? []
        var infos = arrayFromAny(data["sportInfos"])
        if infos.isEmpty { infos = arrayFromAny(data["data"]) }
        for info in infos {
            var entry: [String: Any] = [
                "steps": intFromAny(info["walkSteps"]) ?? intFromAny(info["steps"]) ?? 0,
                "distance": intFromAny(info["walkDistance"]) ?? intFromAny(info["distance"]) ?? 0,
                "calories": intFromAny(info["walkCalories"]) ?? intFromAny(info["calories"]) ?? 0,
                "durationSeconds": intFromAny(info["walkDuration"]) ?? intFromAny(info["duration"]) ?? 0
            ]
            let time = intFromAny(info["startSecs"]) ?? intFromAny(info["time"])
            if let time = time {
                entry["startTime"] = formatTimestamp(Int64(time))
            }
            list.append(entry)
        }
        healthCollector["sport"] = list
    }

    private func formatTimestamp(_ secs: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(secs))
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}
