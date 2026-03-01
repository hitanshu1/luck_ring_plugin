import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'luck_ring_plugin_method_channel.dart';
import 'src/models/health_data.dart';
import 'src/models/scan_device.dart';

abstract class LuckRingPluginPlatform extends PlatformInterface {
  LuckRingPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static LuckRingPluginPlatform _instance = MethodChannelLuckRingPlugin();

  static LuckRingPluginPlatform get instance => _instance;

  static set instance(LuckRingPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  Future<void> init() {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> startScan({int timeoutMs = 12000}) {
    throw UnimplementedError('startScan() has not been implemented.');
  }

  Future<void> stopScan() {
    throw UnimplementedError('stopScan() has not been implemented.');
  }

  Stream<List<ScanDevice>> get scanResults {
    throw UnimplementedError('scanResults has not been implemented.');
  }

  Future<bool> connect(String address) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<void> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  Future<bool> isConnected() {
    throw UnimplementedError('isConnected() has not been implemented.');
  }

  /// Fetches all health data from the connected ring. Triggers sync and waits
  /// for data (up to ~30s). Ensure device is connected before calling.
  Future<HealthData> getHealthData() {
    throw UnimplementedError('getHealthData() has not been implemented.');
  }
}
