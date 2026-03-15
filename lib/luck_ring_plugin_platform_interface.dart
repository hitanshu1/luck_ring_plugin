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

  /// Fetches all health data from the connected ring. Triggers sync and waits
  /// for data (up to ~30s). Ensure device is connected before calling.
  Future<HealthData> getHealthData() {
    throw UnimplementedError('getHealthData() has not been implemented.');
  }
}
