/// A Flutter plugin for interacting with Luck Ring / Coolwear smart rings.
///
/// This library provides classes and methods to scan for, connect to, and
/// retrieve health data (heart rate, blood oxygen, blood pressure, etc.)
/// from compatible wearable devices.
library luck_ring_plugin;

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
  /// Triggers sync, starts real-time measurements (heart rate, SpO2, blood
  /// pressure) and waits up to [timeoutMs] for results before returning the
  /// data collected so far.
  ///
  /// Blood pressure measurement on the ring runs a complete cycle that
  /// typically takes **45–60 seconds** before the first reading is emitted —
  /// shorter timeouts will return empty `bloodPressure` lists. Default is
  /// 60 seconds. Ensure the ring is worn snugly and the wearer stays still
  /// for BP to succeed.
  ///
  /// Ensure [connect] was called successfully before invoking. Returns
  /// aggregated heart rate, blood oxygen, blood pressure, sleep, sport,
  /// battery, and device info.
  Future<HealthData> getHealthData({int timeoutMs = 60000}) =>
      LuckRingPluginPlatform.instance.getHealthData(timeoutMs: timeoutMs);

  /// Push the wearer's demographics to the ring.
  ///
  /// **Call this before [getHealthData] if you want blood-pressure readings.**
  /// The K6 firmware uses sex / age / height / weight as inputs to its
  /// PPG-based BP calculation and on many builds will silently skip the BP
  /// measurement cycle (no readings, no `0x12` packets) if user info hasn't
  /// been set.
  ///
  /// - [sex]: 0 = male, 1 = female
  /// - [age]: years (1–120)
  /// - [heightCm]: centimetres (80–230)
  /// - [weightKg]: kilograms (20–200)
  ///
  /// Any null value keeps the platform's current default for that field.
  Future<void> setUserInfo({int? sex, int? age, int? heightCm, int? weightKg}) =>
      LuckRingPluginPlatform.instance.setUserInfo(
        sex: sex,
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
      );

  /// Platform version (for debugging).
  Future<String?> getPlatformVersion() =>
      LuckRingPluginPlatform.instance.getPlatformVersion();
}
