import Flutter
import UIKit
import CoreBluetooth

public class LuckRingPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?
    private var scanTimer: Timer?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "luck_ring_plugin", binaryMessenger: registrar.messenger())
        let instance = LuckRingPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let eventChannel = FlutterEventChannel(name: "luck_ring_plugin/scan_results", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "init":
            LuckRingSdkBridge.shared.initSdk()
            result(nil)
        case "startScan":
            let args = call.arguments as? [String: Any]
            let timeoutMs = args?["timeoutMs"] as? Int ?? 12000
            LuckRingSdkBridge.shared.startScan(timeoutMs: timeoutMs) { [weak self] devices in
                DispatchQueue.main.async {
                    self?.eventSink?(devices)
                }
            }
            result(nil)
        case "stopScan":
            LuckRingSdkBridge.shared.stopScan()
            result(nil)
        case "connect":
            guard let address = (call.arguments as? [String: Any])?["address"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "address required", details: nil))
                return
            }
            LuckRingSdkBridge.shared.connect(address: address, completion: { connected in
                result(connected)
            })
        case "disconnect":
            LuckRingSdkBridge.shared.disconnect()
            result(nil)
        case "isConnected":
            result(LuckRingSdkBridge.shared.isConnected())
        case "getHealthData":
            LuckRingSdkBridge.shared.getHealthData { data in
                result(data)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
