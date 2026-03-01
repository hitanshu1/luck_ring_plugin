export 'src/models/health_data.dart';
export 'src/models/scan_device.dart';

import 'luck_ring_plugin_platform_interface.dart';
import 'src/models/health_data.dart';
import 'src/models/scan_device.dart';

/// Flutter plugin for Luck Ring / Coolwear Bluetooth SDK.
///
/// Collects health data (heart rate, blood oxygen, blood pressure, sleep, sport)
/// from compatible smart rings via Bluetooth.
class LuckRingPlugin {
  /// Initialize the SDK. Call once before scan/connect.
  Future<void> init() => LuckRingPluginPlatform.instance.init();

  /// Start scanning for nearby devices.
  Future<void> startScan({int timeoutMs = 12000}) =>
      LuckRingPluginPlatform.instance.startScan(timeoutMs: timeoutMs);

  /// Stop scanning.
  Future<void> stopScan() => LuckRingPluginPlatform.instance.stopScan();

  /// Stream of discovered devices during scan.
  Stream<List<ScanDevice>> get scanResults =>
      LuckRingPluginPlatform.instance.scanResults;

  /// Connect to device by MAC address.
  Future<bool> connect(String address) =>
      LuckRingPluginPlatform.instance.connect(address);

  /// Disconnect from device.
  Future<void> disconnect() => LuckRingPluginPlatform.instance.disconnect();

  /// Check if device is connected.
  Future<bool> isConnected() => LuckRingPluginPlatform.instance.isConnected();

  /// Fetch all health data from the connected ring.
  ///
  /// Triggers sync and waits for data. Ensure [connect] was called successfully
  /// before invoking. Returns aggregated heart rate, blood oxygen, blood pressure,
  /// sleep, sport, battery, and device info.
  Future<HealthData> getHealthData() =>
      LuckRingPluginPlatform.instance.getHealthData();

  /// Platform version (for debugging).
  Future<String?> getPlatformVersion() =>
      LuckRingPluginPlatform.instance.getPlatformVersion();
}
