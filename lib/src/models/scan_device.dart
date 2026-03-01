/// A discovered BLE device.
class ScanDevice {
  final String name;
  final String address;
  final String? deviceId;

  const ScanDevice({
    required this.name,
    required this.address,
    this.deviceId,
  });

  factory ScanDevice.fromMap(Map<String, dynamic> map) {
    return ScanDevice(
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      deviceId: map['deviceId'] as String?,
    );
  }

  Map<String, dynamic> toMap() =>
      {'name': name, 'address': address, 'deviceId': deviceId};
}
