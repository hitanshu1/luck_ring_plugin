/// A discovered BLE device during a scan.
class ScanDevice {
  /// The broadcasted name of the device.
  final String name;

  /// The MAC address (Android) or UUID (iOS) of the device.
  final String address;

  /// An optional unique identifier for the device.
  final String? deviceId;

  /// Signal strength of the advertisement in dBm, typically -30 (very close)
  /// to -100 (far away). Null when the platform did not report it.
  final int? rssi;

  /// Creates a new [ScanDevice] instance.
  const ScanDevice({
    required this.name,
    required this.address,
    this.deviceId,
    this.rssi,
  });

  /// Creates a [ScanDevice] instance from a JSON-compatible map.
  factory ScanDevice.fromMap(Map<String, dynamic> map) {
    return ScanDevice(
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      deviceId: map['deviceId'] as String?,
      rssi: (map['rssi'] as num?)?.toInt(),
    );
  }

  /// Converts this instance into a JSON-compatible map.
  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'deviceId': deviceId,
    'rssi': rssi,
  };
}
