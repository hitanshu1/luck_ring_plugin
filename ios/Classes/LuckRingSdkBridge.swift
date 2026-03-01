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

    func getHealthData(completion: @escaping ([String: Any]) -> Void) {
        guard isConnected() else {
            completion(["errorMessage": "Device not connected"])
            return
        }
        healthDataCompletion = completion

        let sdk = CEProductK6.shareInstance()!

        // Open sensor data switch (device only uploads health data when this is on)
        let sensorCmd = CE_SensorCmd()
        sensorCmd.onoff = 1
        sdk.sendCmd(toDevice: sensorCmd, complete: nil)

        // Request battery + device info (quick, lightweight)
        sdk.sendCmd(toDevice: CE_RequestBatteryCmd(), complete: nil)
        sdk.sendCmd(toDevice: CE_RequestDevInfoCmd(), complete: nil)

        // Request historical blood pressure (if device has stored data)
        sdk.sendCmd(toDevice: CE_RequestBloodPresureCmd(), complete: nil)

        // Start real-time heart rate + O2 measurement
        let heartO2 = CE_SyncHeartO2Cmd()
        heartO2.status = 1
        sdk.sendCmd(toDevice: heartO2, complete: nil)

        // Start real-time heart rate measurement
        let hr = CE_SyncHeartRateCmd()
        hr.status = 1
        sdk.sendCmd(toDevice: hr, complete: nil)

        // Start real-time blood pressure measurement
        let bp = CE_SyncBloodPressureCmd()
        bp.status = 1
        sdk.sendCmd(toDevice: bp, complete: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
            guard let self = self else { return }

            // Stop real-time measurements
            let stopHrO2 = CE_SyncHeartO2Cmd()
            stopHrO2.status = 0
            sdk.sendCmd(toDevice: stopHrO2, complete: nil)

            let stopHr = CE_SyncHeartRateCmd()
            stopHr.status = 0
            sdk.sendCmd(toDevice: stopHr, complete: nil)

            let stopBp = CE_SyncBloodPressureCmd()
            stopBp.status = 0
            sdk.sendCmd(toDevice: stopBp, complete: nil)

            if let comp = self.healthDataCompletion {
                NSLog("[LuckRing] getHealthData returning: %@", self.healthCollector as NSDictionary)
                comp(self.healthCollector)
            }
            self.healthDataCompletion = nil
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
        guard let status = noti.object as? NSNumber else { return }
        let s = status.intValue
        if s == 6 { // ProductStatus_completed — pairing done, can communicate
            NSLog("[LuckRing] Device connected & paired, requesting all info")
            healthCollector = [:]
            CEProductK6.shareInstance()?.sendCmd(toDevice: CE_RequestAllInfoCmd(), complete: nil)
            connectCompletion?(true)
            connectCompletion = nil
        } else if s == 4 { // ProductStatus_disconnected
            connectCompletion?(false)
            connectCompletion = nil
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

    @objc private func onReceiveData(_ noti: Notification) {
        // SDK docs: data arrives via userInfo with keys DataType (NSNumber) and Data (NSDictionary)
        let ui = noti.userInfo

        guard let typeNum = ui?["DataType"] as? NSNumber else {
            NSLog("[LuckRing] onReceiveData: no DataType in userInfo. userInfo=%@, object=%@",
                  String(describing: ui), String(describing: noti.object))
            return
        }

        let type = typeNum.intValue
        let d = dictFromAny(ui?["Data"])
        NSLog("[LuckRing] onReceiveData type=0x%02X keys=%@", type, Array(d.keys))

        switch type {
        case 0x07, 0x08, 0x11, 0x18:
            // DATA_TYPE_REAL_HEART, HISTORY_HEART, EXERCISE_HEART, REAL_HR
            parseHeartData(d)
        case 0x14, 40:
            // DATA_TYPE_REAL_O2, DATA_TYPE_HISTORY_O2
            parseO2Data(d)
        case 0x12:
            // DATA_TYPE_REAL_BP
            parseBPData(d)
        case 0x06:
            // DATA_TYPE_SLEEP
            parseSleepData(d)
        case 0x04, 0x05, 0x0a:
            // DATA_TYPE_REAL_SPORT, HISTORY_SPORT, MIX_SPORT
            parseSportData(d)
        case 0x03:
            // DATA_TYPE_BATTERY_INFO
            if let cap = d["battery_capacity"] as? Int {
                healthCollector["batteryLevel"] = cap
            } else if let cap = d["batteryCapacity"] as? Int {
                healthCollector["batteryLevel"] = cap
            } else if let cap = d["battery"] as? Int {
                healthCollector["batteryLevel"] = cap
            } else {
                for (_, v) in d {
                    if let cap = v as? Int, cap >= 0 && cap <= 100 {
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
        default:
            NSLog("[LuckRing] onReceiveData: unhandled type=0x%02X data=%@", type, d as NSDictionary)
        }
    }

    private func parseHeartData(_ data: [String: Any]) {
        var list = healthCollector["heartRate"] as? [[String: Any]] ?? []
        let infos = data["heartInfos"] as? [[String: Any]]
            ?? data["heartRateInfos"] as? [[String: Any]]
            ?? data["data"] as? [[String: Any]]
        if let infos = infos {
            for info in infos {
                let val = info["heartNum"] as? Int
                    ?? info["heartRate"] as? Int
                    ?? info["value"] as? Int ?? 0
                if val <= 0 { continue }
                var entry: [String: Any] = ["value": val]
                if let time = info["time"] as? Int {
                    entry["timestamp"] = formatTimestamp(Int64(time))
                }
                list.append(entry)
            }
        }
        healthCollector["heartRate"] = list
    }

    private func parseO2Data(_ data: [String: Any]) {
        var list = healthCollector["bloodOxygen"] as? [[String: Any]] ?? []
        let arr = data["data"] as? [[String: Any]]
            ?? data["o2Infos"] as? [[String: Any]]
        if let arr = arr {
            for item in arr {
                let val = item["O2"] as? Int
                    ?? item["o2"] as? Int
                    ?? item["value"] as? Int ?? 0
                if val <= 0 { continue }
                var entry: [String: Any] = ["value": val]
                if let time = item["time"] as? Int {
                    entry["timestamp"] = formatTimestamp(Int64(time))
                }
                list.append(entry)
            }
        }
        healthCollector["bloodOxygen"] = list
    }

    private func parseBPData(_ data: [String: Any]) {
        var list = healthCollector["bloodPressure"] as? [[String: Any]] ?? []
        let arr = data["data"] as? [[String: Any]]
            ?? data["bpInfos"] as? [[String: Any]]
        if let arr = arr {
            for item in arr {
                let sys = item["systolic"] as? Int
                    ?? item["highPressure"] as? Int ?? 0
                let dia = item["diastolic"] as? Int
                    ?? item["lowPressure"] as? Int ?? 0
                if sys <= 0 && dia <= 0 { continue }
                var entry: [String: Any] = ["systolic": sys, "diastolic": dia]
                if let time = item["time"] as? Int {
                    entry["timestamp"] = formatTimestamp(Int64(time))
                }
                list.append(entry)
            }
        }
        healthCollector["bloodPressure"] = list
    }

    private func parseSleepData(_ data: [String: Any]) {
        var list = healthCollector["sleep"] as? [[String: Any]] ?? []
        let infos = data["sleepInfos"] as? [[String: Any]]
            ?? data["data"] as? [[String: Any]]
        if let infos = infos {
            for info in infos {
                let stage = info["SleepType"] as? Int
                    ?? info["sleepType"] as? Int
                    ?? info["stage"] as? Int ?? 0
                var entry: [String: Any] = ["stage": stage]
                let time = info["SleepStartTime"] as? Int
                    ?? info["sleepStartTime"] as? Int
                    ?? info["time"] as? Int
                if let time = time {
                    entry["startTime"] = formatTimestamp(Int64(time))
                }
                list.append(entry)
            }
        }
        healthCollector["sleep"] = list
    }

    private func parseSportData(_ data: [String: Any]) {
        var list = healthCollector["sport"] as? [[String: Any]] ?? []
        let infos = data["sportInfos"] as? [[String: Any]]
            ?? data["data"] as? [[String: Any]]
        if let infos = infos {
            for info in infos {
                var entry: [String: Any] = [
                    "steps": info["walkSteps"] as? Int ?? info["steps"] as? Int ?? 0,
                    "distance": info["walkDistance"] as? Int ?? info["distance"] as? Int ?? 0,
                    "calories": info["walkCalories"] as? Int ?? info["calories"] as? Int ?? 0,
                    "durationSeconds": info["walkDuration"] as? Int ?? info["duration"] as? Int ?? 0
                ]
                let time = info["startSecs"] as? Int ?? info["time"] as? Int
                if let time = time {
                    entry["startTime"] = formatTimestamp(Int64(time))
                }
                list.append(entry)
            }
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
