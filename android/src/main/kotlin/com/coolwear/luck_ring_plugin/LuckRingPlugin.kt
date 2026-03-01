package com.coolwear.luck_ring_plugin

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.ConcurrentHashMap

/** Luck Ring Plugin - Coolwear SDK integration */
class LuckRingPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var applicationContext: Context? = null
    private var activity: Activity? = null
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())

    companion object {
        private const val PERMISSION_REQUEST = 3301
        private val BLE_PERMISSIONS = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.ACCESS_FINE_LOCATION
            )
        } else {
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            )
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "luck_ring_plugin")
        channel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "luck_ring_plugin/scan_results")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
        LuckRingSdkHelper.initialized(applicationContext!!)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "init" -> {
                LuckRingSdkHelper.initialized(applicationContext!!)
                result.success(null)
            }
            "startScan" -> {
                if (!hasPermissions()) {
                    requestPermissions(result) { startScanInternal(call, result) }
                } else {
                    startScanInternal(call, result)
                }
            }
            "stopScan" -> {
                LuckRingSdkHelper.stopScan()
                result.success(null)
            }
            "connect" -> {
                val address = call.argument<String>("address")
                if (address.isNullOrEmpty()) {
                    result.error("INVALID_ARGS", "address required", null)
                } else if (!hasPermissions()) {
                    requestPermissions(result) { LuckRingSdkHelper.connect(address, result) }
                } else {
                    LuckRingSdkHelper.connect(address, result)
                }
            }
            "disconnect" -> {
                LuckRingSdkHelper.disconnect()
                result.success(null)
            }
            "isConnected" -> result.success(LuckRingSdkHelper.isConnected())
            "getHealthData" -> {
                if (!LuckRingSdkHelper.isConnected()) {
                    result.success(mapOf("errorMessage" to "Device not connected"))
                } else {
                    LuckRingSdkHelper.getHealthData(result)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun startScanInternal(call: MethodCall, result: Result) {
        val timeoutMs = call.argument<Int>("timeoutMs") ?: 12000
        LuckRingSdkHelper.startScan(timeoutMs) { devices ->
            handler.post { eventSink?.success(devices) }
        }
        result.success(null)
    }

    private fun hasPermissions(): Boolean = BLE_PERMISSIONS.all {
        ContextCompat.checkSelfPermission(applicationContext!!, it) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestPermissions(result: Result, onGranted: () -> Unit) {
        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity required for permissions", null)
            return
        }
        ActivityCompat.requestPermissions(act, BLE_PERMISSIONS, PERMISSION_REQUEST)
        pendingCallback = { if (hasPermissions()) onGranted() else result.error("PERMISSION_DENIED", "Bluetooth permissions required", null) }
    }

    private var pendingCallback: (() -> Unit)? = null

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode == PERMISSION_REQUEST) {
            pendingCallback?.invoke()
            pendingCallback = null
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        applicationContext = null
        eventSink = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener { requestCode, _, _ ->
            if (requestCode == PERMISSION_REQUEST) {
                onRequestPermissionsResult(requestCode, intArrayOf())
                true
            } else false
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
