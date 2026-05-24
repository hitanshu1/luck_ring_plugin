package com.coolwear.luck_ring_plugin

import android.content.Context
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList
import java.util.HashMap
import ce.com.cenewbluesdk.proxy.sdkhelper.BluetoothHelper
import ce.com.cenewbluesdk.entity.k6.K6_Action
import ce.com.cenewbluesdk.CEBC
import ce.com.cenewbluesdk.entity.k6.K6_HeartStruct
import ce.com.cenewbluesdk.entity.k6.K6_DATA_TYPE_REAL_O2
import ce.com.cenewbluesdk.entity.k6.K6_DATA_TYPE_REAL_BP
import ce.com.cenewbluesdk.entity.k6.K6_DevInfoStruct
import ce.com.cenewbluesdk.entity.k6.K6_DATA_TYPE_BATTERY_INFO
import ce.com.cenewbluesdk.entity.k6.K6_Sport
import ce.com.cenewbluesdk.entity.K6_sleepData
import ce.com.cenewbluesdk.proxy.interfaces.K6BleDataResult
import ce.com.cenewbluesdk.entity.MyBleDevice
import ce.com.cenewbluesdk.proxy.interfaces.OnScanDevListener
import ce.com.cenewbluesdk.proxy.interfaces.OnBlueScanCompleteListener
import android.bluetooth.le.ScanResult

object LuckRingSdkHelper {

    private var context: Context? = null
    private var scanCallback: ((List<Map<String, Any?>>) -> Unit)? = null
    private val deviceList = ArrayList<Map<String, Any?>>()
    private val deviceMap = mutableMapOf<String, MyBleDevice>()

    private val healthData = HealthDataCollector()
    private var getHealthDataResult: MethodChannel.Result? = null
    private var healthDataTimeoutRunnable: Runnable? = null

    private val scanListener = object : OnScanDevListener {
        override fun onFindDev(scanRecord: ScanResult?) {
            // Single device - onFindDevList provides aggregated list
        }

        override fun onFindDevList(
            scanRecord: ScanResult?,
            devList: MutableList<MyBleDevice>?,
            myBleDevice: MyBleDevice?
        ) {
            val list = devList?.mapNotNull { dev ->
                dev?.let {
                    val map = toDeviceMap(it)
                    val addr = map["address"] as? String ?: ""
                    if (addr.isNotEmpty()) deviceMap[addr] = it
                    map
                }
            } ?: emptyList()
            synchronized(deviceList) {
                this@LuckRingSdkHelper.deviceList.clear()
                this@LuckRingSdkHelper.deviceList.addAll(list)
            }
            scanCallback?.invoke(ArrayList(this@LuckRingSdkHelper.deviceList))
        }
    }

    private fun toDeviceMap(dev: MyBleDevice): Map<String, Any?> {
        val btAddress = dev.getmBluetoothDevice()?.address
        val macId = dev.macId
        // Prefer macId: SDK extracts real MAC from scan record; btAddress may be masked on Android 12+
        val address = when {
            !macId.isNullOrBlank() && isValidMac(macId) -> macId
            !btAddress.isNullOrBlank() && isValidMac(btAddress) -> btAddress
            !macId.isNullOrBlank() -> macId
            else -> btAddress ?: ""
        }
        return mapOf(
            "name" to (dev.name ?: "Unknown"),
            "address" to address,
            "deviceId" to (macId ?: btAddress ?: "")
        )
    }

    private fun isValidMac(addr: String): Boolean {
        if (addr.length != 17) return false
        if (addr == "02:00:00:00:00:00") return false
        return addr.matches(Regex("^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$"))
    }

    fun initialized(ctx: Context) {
        if (context == null) {
            context = ctx.applicationContext
            BluetoothHelper.getInstance().init()
            BluetoothHelper.getInstance().initProxy(ctx.applicationContext)
        }
    }

    fun startScan(timeoutMs: Int, onDevices: (List<Map<String, Any?>>) -> Unit) {
        context ?: return
        deviceList.clear()
        deviceMap.clear()
        scanCallback = onDevices
        BluetoothHelper.getInstance().scanningDeviceInit(context!!, scanListener)
        BluetoothHelper.getInstance().setScanTimeOut(timeoutMs)
        BluetoothHelper.getInstance().setBlueScanComplete(object : OnBlueScanCompleteListener {
            override fun onBlueScanComplete() {
                scanCallback?.invoke(ArrayList(deviceList))
                scanCallback = null
            }
        })
        BluetoothHelper.getInstance().startScan()
    }

    fun stopScan() {
        BluetoothHelper.getInstance().stopScan()
        scanCallback = null
    }

    fun connect(address: String, result: MethodChannel.Result) {
        val rcv = BluetoothHelper.getInstance().getRcvDataManager()
        val connKey = K6_Action.RCVD.RCVD_BLUE_CONNECT_STATE_CHANGE
        val handler = android.os.Handler(android.os.Looper.getMainLooper())
        var resolved = false

        val listener = object : K6BleDataResult<Int> {
            override fun bleDataResult(status: Int?): Boolean {
                if (resolved) return false
                when (status) {
                    K6_Action.RCVD.BLUE_CONNECTED -> {
                        resolved = true
                        BluetoothHelper.getInstance().devicePairFinish(1)
                        BluetoothHelper.getInstance().setEnableGsDataTrans(true)
                        handler.post { result.success(true) }
                    }
                    K6_Action.RCVD.BLUE_DISCONNECT -> {
                        resolved = true
                        handler.post { result.success(false) }
                    }
                }
                return false
            }
        }
        rcv.addBleDataResultListener(connKey, listener)

        val btDevice = deviceMap[address]?.getmBluetoothDevice()
        val useBtDevice = btDevice != null && !isValidMac(address)
        if (useBtDevice && !connectViaBluetoothDevice(btDevice)) {
            BluetoothHelper.getInstance().connectDev(address, "")
        } else if (!useBtDevice) {
            BluetoothHelper.getInstance().connectDev(address, "")
        }

        handler.postDelayed({
            if (!resolved) {
                resolved = true
                result.success(false)
            }
        }, 15000)
    }

    private fun connectViaBluetoothDevice(device: android.bluetooth.BluetoothDevice): Boolean {
        return try {
            val helper = BluetoothHelper.getInstance()
            val util = helper.javaClass.getMethod("getConnectUtil").invoke(helper)
            val method = util?.javaClass?.methods?.find {
                it.name == "connectDevice" && it.parameterTypes.size == 1 &&
                    it.parameterTypes[0] == android.bluetooth.BluetoothDevice::class.java
            }
            method?.invoke(util, device)
            true
        } catch (e: Exception) {
            android.util.Log.w("LuckRing", "connectDevice(BluetoothDevice) failed", e)
            false
        }
    }

    fun disconnect() {
        BluetoothHelper.getInstance().disConnect()
    }

    fun isConnected(): Boolean = BluetoothHelper.getInstance().isConnectOk()

    /**
     * Demographic profile pushed to the ring before BP measurements.
     * The K6 firmware uses these as inputs to its PPG-based BP calculation;
     * without them many builds silently skip the BP cycle.
     *
     * NOTE: This currently only stores the values — wiring it through to
     * the Android SDK's `sendUserInfo` call is a TODO. The iOS bridge does
     * push these via `CE_SyncUserInfoCmd`.
     */
    @Volatile private var userSex: Int = 0
    @Volatile private var userAge: Int = 30
    @Volatile private var userHeightCm: Int = 170
    @Volatile private var userWeightKg: Int = 70

    fun setUserInfo(sex: Int?, age: Int?, heightCm: Int?, weightKg: Int?) {
        sex?.let { userSex = it.coerceIn(0, 1) }
        age?.let { userAge = it.coerceIn(1, 120) }
        heightCm?.let { userHeightCm = it.coerceIn(80, 230) }
        weightKg?.let { userWeightKg = it.coerceIn(20, 200) }
        android.util.Log.i(
            "LuckRing",
            "setUserInfo sex=$userSex age=$userAge h=$userHeightCm w=$userWeightKg"
        )
        // TODO: when the Android SDK exposes a user-info command, push it
        // here via BluetoothHelper.getInstance().getSendBlueData().
    }

    /**
     * Trigger sync + real-time measurements (HR / SpO2 / BP) and wait up to
     * [timeoutMs] before returning whatever was collected.
     *
     * Blood pressure runs a single measurement cycle on the ring that
     * typically takes ~45-60 seconds before the first reading is pushed, so
     * keep [timeoutMs] >= 60_000 to actually receive BP data.
     */
    fun getHealthData(timeoutMs: Long, result: MethodChannel.Result) {
        val handler = android.os.Handler(android.os.Looper.getMainLooper())

        // Cancel any previously-scheduled finish so we don't double-fire.
        healthDataTimeoutRunnable?.let { handler.removeCallbacks(it) }
        healthDataTimeoutRunnable = null

        healthData.clear()
        getHealthDataResult = result
        registerHealthListeners()
        BluetoothHelper.getInstance().synDevData()
        val sendData = BluetoothHelper.getInstance().getSendBlueData()
        sendData.sendHeartRateSwitch(CEBC.OPENSTATUS.OPEN)
        sendData.sendBloodOxygenDetection(CEBC.OPENSTATUS.OPEN)
        sendData.sendBloodPressureDetection(CEBC.OPENSTATUS.OPEN)

        val wait = timeoutMs.coerceAtLeast(5000L)
        android.util.Log.i("LuckRing", "getHealthData: waiting ${wait}ms (BP needs ~45-60s)")

        healthDataTimeoutRunnable = Runnable {
            try {
                val s = BluetoothHelper.getInstance().getSendBlueData()
                s.sendHeartRateSwitch(CEBC.OPENSTATUS.CLOSE)
                s.sendBloodOxygenDetection(CEBC.OPENSTATUS.CLOSE)
                s.sendBloodPressureDetection(CEBC.OPENSTATUS.CLOSE)
            } catch (e: Exception) {
                android.util.Log.w("LuckRing", "stop detection failed", e)
            }
            unregisterHealthListeners()
            val map = healthData.toMap()
            android.util.Log.i(
                "LuckRing",
                "getHealthData done: hr=${(map["heartRate"] as? List<*>)?.size} " +
                    "o2=${(map["bloodOxygen"] as? List<*>)?.size} " +
                    "bp=${(map["bloodPressure"] as? List<*>)?.size}"
            )
            getHealthDataResult?.success(map)
            getHealthDataResult = null
            healthDataTimeoutRunnable = null
        }
        handler.postDelayed(healthDataTimeoutRunnable!!, wait)
    }

    private fun registerHealthListeners() {
        val rcv = BluetoothHelper.getInstance().getRcvDataManager()

        val heartCb = K6BleDataResult<ArrayList<K6_HeartStruct>> { list ->
            list?.forEach { hr ->
                val value = hr.heartNums
                if (value > 0) healthData.addHeartRate(value, hr.time)
            }
            false
        }
        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_SPORT_HEART_FOR_SHOW, heartCb)
        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_DAILY_HEART, heartCb)
        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_SPORT_HEART, heartCb)

        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_DATA_TYPE_REAL_O2,
            K6BleDataResult { list: ArrayList<K6_DATA_TYPE_REAL_O2>? ->
                list?.forEach { o2 ->
                    if (o2.value > 0) {
                        healthData.addBloodOxygen(o2.value, o2.time.toLong())
                    }
                }
                false
            })

        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_DATA_TYPE_REAL_BP,
            K6BleDataResult { list: ArrayList<K6_DATA_TYPE_REAL_BP>? ->
                android.util.Log.d("LuckRing", "BP listener fired: size=${list?.size}")
                list?.forEach { bp ->
                    // The K6 SDK pushes a synthetic 0/0 reading with isEnd=true
                    // while a measurement is still in progress; skip those so we
                    // only surface completed readings.
                    if (bp.isEnd()) {
                        android.util.Log.d("LuckRing", "BP isEnd marker, skipping")
                        return@forEach
                    }
                    if (bp.bp_sbp <= 0 && bp.bp_dbp <= 0) {
                        android.util.Log.d("LuckRing", "BP 0/0 reading, skipping")
                        return@forEach
                    }
                    android.util.Log.i(
                        "LuckRing",
                        "BP reading sbp=${bp.bp_sbp} dbp=${bp.bp_dbp} time=${bp.time}"
                    )
                    healthData.addBloodPressure(bp.bp_sbp, bp.bp_dbp, bp.time.toLong())
                }
                false
            })

        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_K6_SLEEP_DATA,
            K6BleDataResult { data: K6_sleepData? ->
                data?.let { healthData.addSleep(it) }
                false
            })

        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_SPORT_DATA,
            K6BleDataResult { list: ArrayList<K6_Sport>? ->
                list?.forEach { s ->
                    healthData.addSport(
                        s.starTime.toLong(),
                        s.walkSteps,
                        s.distance,
                        s.calories,
                        s.duration
                    )
                }
                false
            })

        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_BATTERY,
            K6BleDataResult { info: K6_DATA_TYPE_BATTERY_INFO? ->
                info?.let { healthData.setBattery(it.battery) }
                false
            })

        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_DEVINFO,
            K6BleDataResult { dev: K6_DevInfoStruct? ->
                dev?.let { healthData.setDeviceInfo(null, it.softwareVer, it.code_id.toString()) }
                false
            })
    }

    private fun unregisterHealthListeners() {
        // SDK may not support remove - listeners will stop being called when we no longer reference them
    }
}
