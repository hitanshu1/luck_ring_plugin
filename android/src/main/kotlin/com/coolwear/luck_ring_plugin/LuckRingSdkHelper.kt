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

    fun getHealthData(result: MethodChannel.Result) {
        healthData.clear()
        getHealthDataResult = result
        registerHealthListeners()
        BluetoothHelper.getInstance().synDevData()
        val sendData = BluetoothHelper.getInstance().getSendBlueData()
        sendData.sendHeartRateSwitch(CEBC.OPENSTATUS.OPEN)
        sendData.sendBloodOxygenDetection(CEBC.OPENSTATUS.OPEN)
        sendData.sendBloodPressureDetection(CEBC.OPENSTATUS.OPEN)

        val handler = android.os.Handler(android.os.Looper.getMainLooper())
        healthDataTimeoutRunnable = Runnable {
            // Stop detection to save battery
            val sendData = BluetoothHelper.getInstance().getSendBlueData()
            sendData.sendHeartRateSwitch(CEBC.OPENSTATUS.CLOSE)
            sendData.sendBloodOxygenDetection(CEBC.OPENSTATUS.CLOSE)
            sendData.sendBloodPressureDetection(CEBC.OPENSTATUS.CLOSE)
            unregisterHealthListeners()
            val map = healthData.toMap()
            getHealthDataResult?.success(map)
            getHealthDataResult = null
        }
        handler.postDelayed(healthDataTimeoutRunnable!!, 25000)
    }

    private fun registerHealthListeners() {
        val rcv = BluetoothHelper.getInstance().getRcvDataManager()

        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_SPORT_HEART_FOR_SHOW,
            K6BleDataResult { list: ArrayList<K6_HeartStruct>? ->
                list?.forEach { hr ->
                    val value = hr.heartNums ?: 0
                    healthData.addHeartRate(value, hr.time)
                }
                false
            })

        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_DAILY_HEART,
            K6BleDataResult { list: ArrayList<K6_HeartStruct>? ->
                list?.forEach { hr ->
                    val value = hr.heartNums ?: 0
                    healthData.addHeartRate(value, hr.time)
                }
                false
            })

        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_SPORT_HEART,
            K6BleDataResult { list: ArrayList<K6_HeartStruct>? ->
                list?.forEach { hr ->
                    val value = hr.heartNums ?: 0
                    healthData.addHeartRate(value, hr.time)
                }
                false
            })

        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_DATA_TYPE_REAL_O2,
            K6BleDataResult { list: ArrayList<K6_DATA_TYPE_REAL_O2>? ->
                list?.forEach { o2 ->
                    healthData.addBloodOxygen(o2.value, o2.time.toLong())
                }
                false
            })

        rcv.addBleDataResultListener(K6_Action.RCVD.RCVD_DATA_TYPE_REAL_BP,
            K6BleDataResult { list: ArrayList<K6_DATA_TYPE_REAL_BP>? ->
                list?.forEach { bp ->
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
