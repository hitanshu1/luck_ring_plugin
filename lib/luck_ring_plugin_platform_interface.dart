import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'luck_ring_plugin_method_channel.dart';
import 'src/models/health_data.dart';
import 'src/models/scan_device.dart';

/// The interface that implementations of luck_ring_plugin must implement.
///
/// Platform implementations should extend this class rather than implement it as `luck_ring_plugin`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [LuckRingPluginPlatform] methods.
abstract class LuckRingPluginPlatform extends PlatformInterface {
  /// Constructs a [LuckRingPluginPlatform].
  LuckRingPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static LuckRingPluginPlatform _instance = MethodChannelLuckRingPlugin();

  /// The default instance of [LuckRingPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelLuckRingPlugin].
  static LuckRingPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LuckRingPluginPlatform] when
  /// they register themselves.
  static set instance(LuckRingPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the platform version string.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  /// Initializes the SDK.
  Future<void> init() {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// Starts scanning for nearby devices.
  Future<void> startScan({int timeoutMs = 12000}) {
    throw UnimplementedError('startScan() has not been implemented.');
  }

  /// Stops the current scan.
  Future<void> stopScan() {
    throw UnimplementedError('stopScan() has not been implemented.');
  }

  /// Stream of discovered devices.
  Stream<List<ScanDevice>> get scanResults {
    throw UnimplementedError('scanResults has not been implemented.');
  }

  /// Connects to a device by its MAC address.
  Future<bool> connect(String address) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  /// Disconnects from the current device.
  Future<void> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  /// Returns true if a device is currently connected.
  Future<bool> isConnected() {
    throw UnimplementedError('isConnected() has not been implemented.');
  }

  /// Fetches all health data from the connected ring.
  ///
  /// Triggers a sync and starts real-time measurements (heart rate, blood oxygen,
  /// blood pressure) on the device, then waits up to [timeoutMs] milliseconds
  /// for results before returning whatever data was collected.
  ///
  /// Blood pressure (BP) is significantly slower than heart rate / SpO2 — the
  /// ring runs a single measurement cycle that typically takes 45–60 seconds
  /// before it pushes the first BP reading. If you need BP readings, keep
  /// [timeoutMs] at the default (60s) or higher and make sure the ring is
  /// worn snugly and the wearer stays still while measuring.
  ///
  /// Ensure [connect] was called successfully before calling this method.
  Future<HealthData> getHealthData({int timeoutMs = 60000}) {
    throw UnimplementedError('getHealthData() has not been implemented.');
  }

  /// Pushes the wearer's demographics to the ring.
  ///
  /// The K6 firmware uses sex / age / height / weight as inputs to its
  /// PPG-based blood pressure calculation. On many builds the ring will
  /// **silently refuse to start the BP measurement cycle** until user info
  /// has been set, so call this once after [connect] (or any time the
  /// profile changes) and before [getHealthData] if you need BP readings.
  ///
  /// - [sex]: 0 = male, 1 = female
  /// - [age]: years (1–120)
  /// - [heightCm]: centimetres (80–230)
  /// - [weightKg]: kilograms, rounded (20–200)
  ///
  /// Any null value keeps the previously-stored default for that field.
  Future<void> setUserInfo({int? sex, int? age, int? heightCm, int? weightKg}) {
    throw UnimplementedError('setUserInfo() has not been implemented.');
  }
}
