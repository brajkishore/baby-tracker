class StatusSnapshot {
  const StatusSnapshot({
    this.lat,
    this.lng,
    this.accuracy,
    this.batteryPct,
    this.isCharging,
    this.networkType = 'offline',
    this.screenState = 'UNKNOWN',
    this.motionState = 'stationary',
    this.speed,
    this.confidence,
    this.geofenceState = 'unknown',
  });

  final double? lat;
  final double? lng;
  final double? accuracy;
  final int? batteryPct;
  final bool? isCharging;
  final String networkType;
  final String screenState;
  final String motionState;
  final double? speed;
  final double? confidence;
  final String geofenceState;

  StatusSnapshot copyWith({
    double? lat,
    double? lng,
    double? accuracy,
    int? batteryPct,
    bool? isCharging,
    String? networkType,
    String? screenState,
    String? motionState,
    double? speed,
    double? confidence,
    String? geofenceState,
  }) {
    return StatusSnapshot(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracy: accuracy ?? this.accuracy,
      batteryPct: batteryPct ?? this.batteryPct,
      isCharging: isCharging ?? this.isCharging,
      networkType: networkType ?? this.networkType,
      screenState: screenState ?? this.screenState,
      motionState: motionState ?? this.motionState,
      speed: speed ?? this.speed,
      confidence: confidence ?? this.confidence,
      geofenceState: geofenceState ?? this.geofenceState,
    );
  }
}
