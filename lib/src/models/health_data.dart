/// Aggregated health data from the Luck Ring / Coolwear device.
class HealthData {
  /// List of heart rate measurements.
  final List<HeartRateReading> heartRate;

  /// List of blood oxygen (SpO2) measurements.
  final List<BloodOxygenReading> bloodOxygen;

  /// List of blood pressure measurements.
  final List<BloodPressureReading> bloodPressure;

  /// List of sleep session records.
  final List<SleepRecord> sleep;

  /// List of activity and sport records.
  final List<SportRecord> sport;

  /// Current battery level percentage (0-100).
  final int? batteryLevel;

  /// Static device information.
  final DeviceInfo? deviceInfo;

  /// Error message if data retrieval failed.
  final String? errorMessage;

  /// Creates a new [HealthData] instance.
  const HealthData({
    this.heartRate = const [],
    this.bloodOxygen = const [],
    this.bloodPressure = const [],
    this.sleep = const [],
    this.sport = const [],
    this.batteryLevel,
    this.deviceInfo,
    this.errorMessage,
  });

  /// Creates a [HealthData] instance from a JSON-compatible map.
  factory HealthData.fromMap(Map<String, dynamic> map) {
    return HealthData(
      heartRate: (map['heartRate'] as List<dynamic>?)
              ?.map((e) => HeartRateReading.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      bloodOxygen: (map['bloodOxygen'] as List<dynamic>?)
              ?.map((e) => BloodOxygenReading.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      bloodPressure: (map['bloodPressure'] as List<dynamic>?)
              ?.map((e) => BloodPressureReading.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      sleep: (map['sleep'] as List<dynamic>?)
              ?.map((e) => SleepRecord.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      sport: (map['sport'] as List<dynamic>?)
              ?.map((e) => SportRecord.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      batteryLevel: map['batteryLevel'] as int?,
      deviceInfo: map['deviceInfo'] != null
          ? DeviceInfo.fromMap(Map<String, dynamic>.from(map['deviceInfo'] as Map))
          : null,
      errorMessage: map['errorMessage'] as String?,
    );
  }

  /// Converts this instance into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'heartRate': heartRate.map((e) => e.toMap()).toList(),
      'bloodOxygen': bloodOxygen.map((e) => e.toMap()).toList(),
      'bloodPressure': bloodPressure.map((e) => e.toMap()).toList(),
      'sleep': sleep.map((e) => e.toMap()).toList(),
      'sport': sport.map((e) => e.toMap()).toList(),
      'batteryLevel': batteryLevel,
      'deviceInfo': deviceInfo?.toMap(),
      'errorMessage': errorMessage,
    };
  }
}

/// A single heart rate measurement.
class HeartRateReading {
  /// Heart rate value in beats per minute (BPM).
  final int value;

  /// When the measurement was taken.
  final DateTime? timestamp;

  /// Creates a new [HeartRateReading] instance.
  const HeartRateReading({required this.value, this.timestamp});

  /// Creates a [HeartRateReading] instance from a JSON-compatible map.
  factory HeartRateReading.fromMap(Map<String, dynamic> map) {
    return HeartRateReading(
      value: map['value'] as int? ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {'value': value, 'timestamp': timestamp?.toIso8601String()};
}

/// A single blood oxygen (SpO2) measurement.
class BloodOxygenReading {
  /// Blood oxygen saturation percentage.
  final int value;

  /// When the measurement was taken.
  final DateTime? timestamp;

  /// Creates a new [BloodOxygenReading] instance.
  const BloodOxygenReading({required this.value, this.timestamp});

  /// Creates a [BloodOxygenReading] instance from a JSON-compatible map.
  factory BloodOxygenReading.fromMap(Map<String, dynamic> map) {
    return BloodOxygenReading(
      value: map['value'] as int? ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {'value': value, 'timestamp': timestamp?.toIso8601String()};
}

/// A single blood pressure measurement.
class BloodPressureReading {
  /// Systolic blood pressure value.
  final int systolic;

  /// Diastolic blood pressure value.
  final int diastolic;

  /// When the measurement was taken.
  final DateTime? timestamp;

  /// Creates a new [BloodPressureReading] instance.
  const BloodPressureReading({
    required this.systolic,
    required this.diastolic,
    this.timestamp,
  });

  /// Creates a [BloodPressureReading] instance from a JSON-compatible map.
  factory BloodPressureReading.fromMap(Map<String, dynamic> map) {
    return BloodPressureReading(
      systolic: map['systolic'] as int? ?? 0,
      diastolic: map['diastolic'] as int? ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() =>
      {'systolic': systolic, 'diastolic': diastolic, 'timestamp': timestamp?.toIso8601String()};
}

/// A record of a sleep session.
///
/// Sleep stage: 0=none, 1=start, 2=deep, 3=light, 4=wakeup, 5=rem
class SleepRecord {
  /// When the sleep stage started.
  final DateTime? startTime;

  /// The sleep stage type (e.g., deep, light, rem).
  final int stage; // SLEEP_STATUS_TYPE

  /// Duration of this sleep stage in minutes.
  final int? durationMinutes;

  /// Creates a new [SleepRecord] instance.
  const SleepRecord({
    this.startTime,
    required this.stage,
    this.durationMinutes,
  });

  /// Creates a [SleepRecord] instance from a JSON-compatible map.
  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(
      startTime: map['startTime'] != null
          ? DateTime.tryParse(map['startTime'] as String)
          : null,
      stage: map['stage'] as int? ?? 0,
      durationMinutes: map['durationMinutes'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        'startTime': startTime?.toIso8601String(),
        'stage': stage,
        'durationMinutes': durationMinutes,
      };
}

/// A record of physical activity or sport.
class SportRecord {
  /// When the activity started.
  final DateTime? startTime;

  /// Total steps taken during this activity.
  final int steps;

  /// Distance covered in meters.
  final int distance; // meters

  /// Estimated calories burned.
  final int calories;

  /// Total duration of the activity in seconds.
  final int durationSeconds;

  /// Creates a new [SportRecord] instance.
  const SportRecord({
    this.startTime,
    this.steps = 0,
    this.distance = 0,
    this.calories = 0,
    this.durationSeconds = 0,
  });

  /// Creates a [SportRecord] instance from a JSON-compatible map.
  factory SportRecord.fromMap(Map<String, dynamic> map) {
    return SportRecord(
      startTime: map['startTime'] != null
          ? DateTime.tryParse(map['startTime'] as String)
          : null,
      steps: map['steps'] as int? ?? 0,
      distance: map['distance'] as int? ?? 0,
      calories: map['calories'] as int? ?? 0,
      durationSeconds: map['durationSeconds'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'startTime': startTime?.toIso8601String(),
        'steps': steps,
        'distance': distance,
        'calories': calories,
        'durationSeconds': durationSeconds,
      };
}

/// Information about the connected device.
class DeviceInfo {
  /// MAC address of the device.
  final String? macAddress;

  /// Firmware or software version of the device.
  final String? version;

  /// Unique identifier designated by the system.
  final String? deviceId;

  /// Creates a new [DeviceInfo] instance.
  const DeviceInfo({
    this.macAddress,
    this.version,
    this.deviceId,
  });

  /// Creates a [DeviceInfo] instance from a JSON-compatible map.
  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      macAddress: map['macAddress'] as String?,
      version: map['version'] as String?,
      deviceId: map['deviceId'] as String?,
    );
  }

  Map<String, dynamic> toMap() =>
      {'macAddress': macAddress, 'version': version, 'deviceId': deviceId};
}
