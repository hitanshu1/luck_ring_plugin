package com.coolwear.luck_ring_plugin

import ce.com.cenewbluesdk.entity.K6_sleepData
import java.util.ArrayList
import java.util.Calendar
import java.util.HashMap

internal class HealthDataCollector {

    private val heartRateList = ArrayList<HashMap<String, Any?>>()
    private val bloodOxygenList = ArrayList<HashMap<String, Any?>>()
    private val bloodPressureList = ArrayList<HashMap<String, Any?>>()
    private val sleepList = ArrayList<HashMap<String, Any?>>()
    private val sportList = ArrayList<HashMap<String, Any?>>()
    private var batteryLevel: Int? = null
    private var deviceInfo: HashMap<String, String?>? = null

    fun clear() {
        heartRateList.clear()
        bloodOxygenList.clear()
        bloodPressureList.clear()
        sleepList.clear()
        sportList.clear()
        batteryLevel = null
        deviceInfo = null
    }

    fun addHeartRate(value: Int, time: Long?) {
        val map = HashMap<String, Any?>()
        map["value"] = value
        map["timestamp"] = time?.let { formatTimestamp(it) }
        heartRateList.add(map)
    }

    fun addBloodOxygen(value: Int, time: Long?) {
        val map = HashMap<String, Any?>()
        map["value"] = value
        map["timestamp"] = time?.let { formatTimestamp(it) }
        bloodOxygenList.add(map)
    }

    fun addBloodPressure(systolic: Int, diastolic: Int, time: Long?) {
        val map = HashMap<String, Any?>()
        map["systolic"] = systolic
        map["diastolic"] = diastolic
        map["timestamp"] = time?.let { formatTimestamp(it) }
        bloodPressureList.add(map)
    }

    fun addSleep(data: K6_sleepData) {
        try {
            val infos = data.sleepInfos
            if (!infos.isNullOrEmpty()) {
                for (info in infos) {
                    val map = HashMap<String, Any?>()
                    try {
                        val time = info.javaClass.getMethod("getSleepStartTime")?.invoke(info)
                        map["startTime"] = (time as? Number)?.longValue()?.let { formatTimestamp(it) }
                    } catch (_: Exception) {}
                    try {
                        val stage = info.javaClass.getMethod("getSleepType")?.invoke(info) as? Number
                        map["stage"] = stage?.intValue() ?: 0
                    } catch (_: Exception) { map["stage"] = 0 }
                    sleepList.add(map)
                }
            }
        } catch (_: Exception) { }
    }

    fun addSport(
        startSecs: Long?,
        steps: Int,
        distance: Int,
        calories: Int,
        durationSeconds: Int
    ) {
        val map = HashMap<String, Any?>()
        map["startTime"] = startSecs?.let { formatTimestamp(it) }
        map["steps"] = steps
        map["distance"] = distance
        map["calories"] = calories
        map["durationSeconds"] = durationSeconds
        sportList.add(map)
    }

    fun setBattery(level: Int) {
        batteryLevel = level
    }

    fun setDeviceInfo(mac: String?, version: String?, id: String?) {
        deviceInfo = HashMap<String, String?>().apply {
            put("macAddress", mac)
            put("version", version)
            put("deviceId", id)
        }
    }

    fun toMap(): Map<String, Any?> {
        val result = HashMap<String, Any?>()
        result["heartRate"] = ArrayList(heartRateList)
        result["bloodOxygen"] = ArrayList(bloodOxygenList)
        result["bloodPressure"] = ArrayList(bloodPressureList)
        result["sleep"] = ArrayList(sleepList)
        result["sport"] = ArrayList(sportList)
        batteryLevel?.let { result["batteryLevel"] = it }
        deviceInfo?.let { result["deviceInfo"] = it }
        return result
    }

    private fun formatTimestamp(secs: Long): String {
        val cal = Calendar.getInstance()
        cal.timeInMillis = secs * 1000
        return java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", java.util.Locale.US).apply {
            timeZone = java.util.TimeZone.getTimeZone("UTC")
        }.format(cal.time)
    }
}
