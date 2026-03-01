import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'luck_ring_plugin_platform_interface.dart';
import 'src/models/health_data.dart';
import 'src/models/scan_device.dart';

class MethodChannelLuckRingPlugin extends LuckRingPluginPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('luck_ring_plugin');

  @visibleForTesting
  final eventChannel = const EventChannel('luck_ring_plugin/scan_results');

  Stream<List<ScanDevice>>? _scanResults;

  @override
  Future<String?> getPlatformVersion() async {
    return methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  @override
  Future<void> init() async {
    await methodChannel.invokeMethod('init');
  }

  @override
  Future<void> startScan({int timeoutMs = 12000}) async {
    await methodChannel.invokeMethod('startScan', {'timeoutMs': timeoutMs});
  }

  @override
  Future<void> stopScan() async {
    await methodChannel.invokeMethod('stopScan');
  }

  @override
  Stream<List<ScanDevice>> get scanResults {
    _scanResults ??= eventChannel
        .receiveBroadcastStream()
        .map((e) {
          if (e is! List) return <ScanDevice>[];
          return e
              .whereType<Map>()
              .map((i) {
                try {
                  return ScanDevice.fromMap(Map<String, dynamic>.from(i));
                } catch (_) {
                  return null;
                }
              })
              .whereType<ScanDevice>()
              .toList();
        })
        .handleError((_) {});
    return _scanResults!;
  }

  @override
  Future<bool> connect(String address) async {
    final result = await methodChannel.invokeMethod<bool>('connect', {'address': address});
    return result == true;
  }

  @override
  Future<void> disconnect() async {
    await methodChannel.invokeMethod('disconnect');
  }

  @override
  Future<bool> isConnected() async {
    final result = await methodChannel.invokeMethod<bool>('isConnected');
    return result == true;
  }

  @override
  Future<HealthData> getHealthData() async {
    final map = await methodChannel.invokeMethod<Map<Object?, Object?>>('getHealthData');
    if (map == null) {
      return const HealthData(errorMessage: 'No data received');
    }
    return HealthData.fromMap(Map<String, dynamic>.from(map));
  }
}
