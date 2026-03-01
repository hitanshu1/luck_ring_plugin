# Luck Ring Plugin – Implementation Guide

Flutter plugin for collecting health data from Luck Ring / Coolwear smart rings via Bluetooth on **Android** and **iOS**.

## Features

- Scan for nearby Luck Ring devices
- Connect / disconnect via Bluetooth
- Single `getHealthData()` API returning aggregated health data:
  - Heart rate
  - Blood oxygen
  - Blood pressure
  - Sleep
  - Sport / activity
  - Battery level
  - Device info

---

## Installation

### 1. Add dependency

```yaml
dependencies:
  luck_ring_plugin:
    path: ../luck_ring_plugin   # or git / pub version
  permission_handler: ^11.3.1  # for runtime permissions
```

### 2. Request permissions

Bluetooth and location (for BLE scanning) must be requested before use:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location,
  ].request();
}
```

---

## Usage

### Initialize

```dart
final plugin = LuckRingPlugin();
await plugin.init();
```

### Scan for devices

```dart
await plugin.startScan(timeoutMs: 12000);

plugin.scanResults.listen((devices) {
  for (final d in devices) {
    print('${d.name} - ${d.address}');
  }
});

// Stop when done
await plugin.stopScan();
```

### Connect

```dart
final connected = await plugin.connect(device.address);
if (connected) {
  print('Connected');
}
```

### Get health data

```dart
final healthData = await plugin.getHealthData();

print('Battery: ${healthData.batteryLevel}%');
print('Heart rate readings: ${healthData.heartRate.length}');
print('Blood oxygen: ${healthData.bloodOxygen.length}');
print('Sleep records: ${healthData.sleep.length}');
print('Sport records: ${healthData.sport.length}');
```

### Disconnect

```dart
await plugin.disconnect();
```

---

## Platform setup

### Android

The plugin adds required permissions and the SDK `ContentProvider`. No extra config in your app is needed.

**Minimum SDK:** 23  
**Permissions (added automatically):**

- `BLUETOOTH`, `BLUETOOTH_ADMIN`, `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`
- `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`

### iOS

Add to **Info.plist**:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to connect to your Luck Ring and collect health data.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location is used for Bluetooth device discovery on iOS.</string>
```

**Minimum iOS:** 13.0

---

## Data models

### HealthData

| Field          | Type                    | Description                    |
|----------------|-------------------------|--------------------------------|
| heartRate      | List&lt;HeartRateReading&gt; | Heart rate readings            |
| bloodOxygen    | List&lt;BloodOxygenReading&gt; | Blood oxygen readings      |
| bloodPressure  | List&lt;BloodPressureReading&gt; | Blood pressure readings  |
| sleep          | List&lt;SleepRecord&gt;  | Sleep stage records            |
| sport          | List&lt;SportRecord&gt;  | Activity / sport records       |
| batteryLevel   | int?                    | 0–100                          |
| deviceInfo     | DeviceInfo?             | MAC, version, ID               |
| errorMessage   | String?                 | Error description if any       |

### ScanDevice

| Field   | Type   |
|---------|--------|
| name    | String |
| address | String |
| deviceId| String?|

---

## Example app

The `example/` app shows:

1. Permission handling
2. Scan → device list → connect flow
3. `getHealthData()` call and display

Run it:

```bash
cd luck_ring_plugin/example
flutter run
```

---

## Troubleshooting

- **No devices found:** Enable Bluetooth, grant location permission, and ensure the ring is in pairing mode.
- **Connection fails:** Confirm the ring is not connected to another device.
- **Empty health data:** Connect first, wait a few seconds after pairing, then call `getHealthData()`. Sync can take up to ~25 seconds.
- **iOS: “Device not connected”:** Use the address from `scanResults` (or MAC from QR) when calling `connect()`.

---

## SDK details

- **Android:** Uses Coolwear Blue SDK (`coolwear_bluesdk-release.aar`) via platform channel.
- **iOS:** Uses BluetoothLibrary.framework via platform channel.
- Health data is synced from the device; `getHealthData()` triggers sync and waits for the result.
