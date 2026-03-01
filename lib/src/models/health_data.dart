/// Aggregated health data from the Luck Ring / Coolwear device.
class HealthData {
  final List<HeartRateReading> heartRate;
  final List<BloodOxygenReading> bloodOxygen;
  final List<BloodPressureReading> bloodPressure;
  final List<SleepRecord> sleep;
  final List<SportRecord> sport;
  final int? batteryLevel;
  final DeviceInfo? deviceInfo;
  final String? errorMessage;

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

class HeartRateReading {
  final int value;
  final DateTime? timestamp;

  const HeartRateReading({required this.value, this.timestamp});

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

class BloodOxygenReading {
  final int value;
  final DateTime? timestamp;

  const BloodOxygenReading({required this.value, this.timestamp});

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

class BloodPressureReading {
  final int systolic;
  final int diastolic;
  final DateTime? timestamp;

  const BloodPressureReading({
    required this.systolic,
    required this.diastolic,
    this.timestamp,
  });

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

/// Sleep stage: 0=none, 1=start, 2=deep, 3=light, 4=wakeup, 5=rem
class SleepRecord {
  final DateTime? startTime;
  final int stage; // SLEEP_STATUS_TYPE
  final int? durationMinutes;

  const SleepRecord({
    this.startTime,
    required this.stage,
    this.durationMinutes,
  });

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

class SportRecord {
  final DateTime? startTime;
  final int steps;
  final int distance; // meters
  final int calories;
  final int durationSeconds;

  const SportRecord({
    this.startTime,
    this.steps = 0,
    this.distance = 0,
    this.calories = 0,
    this.durationSeconds = 0,
  });

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

class DeviceInfo {
  final String? macAddress;
  final String? version;
  final String? deviceId;

  const DeviceInfo({
    this.macAddress,
    this.version,
    this.deviceId,
  });

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
