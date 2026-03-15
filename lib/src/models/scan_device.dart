/// A discovered BLE device during a scan.
class ScanDevice {
  /// The broadcasted name of the device.
  final String name;

  /// The MAC address (Android) or UUID (iOS) of the device.
  final String address;

  /// An optional unique identifier for the device.
  final String? deviceId;

  /// Creates a new [ScanDevice] instance.
  const ScanDevice({
    required this.name,
    required this.address,
    this.deviceId,
  });

  /// Creates a [ScanDevice] instance from a JSON-compatible map.
  factory ScanDevice.fromMap(Map<String, dynamic> map) {
    return ScanDevice(
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      deviceId: map['deviceId'] as String?,
    );
  }

  /// Converts this instance into a JSON-compatible map.
  Map<String, dynamic> toMap() =>
      {'name': name, 'address': address, 'deviceId': deviceId};
}

