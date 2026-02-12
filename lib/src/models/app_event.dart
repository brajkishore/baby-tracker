import 'dart:convert';

enum EventPriority { high, medium, low }

enum EventType {
  heartbeat,
  locationUpdate,
  batteryStatus,
  networkStatus,
  screenState,
  motionState,
  geofenceExit,
  batteryLow,
  networkLost,
  gpsDisabled,
  permissionRevoked,
  appHeartbeatMissed,
  screenOffMoving,
  motionSuddenJerk,
  motionPossibleDrop,
}

class AppEvent {
  AppEvent({
    required this.eventId,
    required this.deviceId,
    required this.eventType,
    required this.priority,
    required this.timestamp,
    this.lat,
    this.lng,
    this.batteryPct,
    this.isCharging,
    this.networkType,
    this.screenState,
    this.motionState,
    this.speed,
    this.confidence,
    this.value,
    this.synced = false,
  });

  final String eventId;
  final String deviceId;
  final EventType eventType;
  final EventPriority priority;
  final DateTime timestamp;
  final double? lat;
  final double? lng;
  final int? batteryPct;
  final bool? isCharging;
  final String? networkType;
  final String? screenState;
  final String? motionState;
  final double? speed;
  final double? confidence;
  final String? value;
  bool synced;

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'device_id': deviceId,
      'event_type': eventType.name,
      'priority': priority.name,
      'timestamp': timestamp.toIso8601String(),
      'lat': lat,
      'lng': lng,
      'battery_pct': batteryPct,
      'is_charging': isCharging,
      'network_type': networkType,
      'screen_state': screenState,
      'motion_state': motionState,
      'speed': speed,
      'confidence': confidence,
      'value': value,
      'synced': synced,
    };
  }

  factory AppEvent.fromMap(Map<dynamic, dynamic> map) {
    return AppEvent(
      eventId: map['event_id'] as String,
      deviceId: map['device_id'] as String,
      eventType: EventType.values.firstWhere(
        (e) => e.name == map['event_type'],
        orElse: () => EventType.heartbeat,
      ),
      priority: EventPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => EventPriority.low,
      ),
      timestamp: DateTime.parse(map['timestamp'] as String),
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      batteryPct: map['battery_pct'] as int?,
      isCharging: map['is_charging'] as bool?,
      networkType: map['network_type'] as String?,
      screenState: map['screen_state'] as String?,
      motionState: map['motion_state'] as String?,
      speed: (map['speed'] as num?)?.toDouble(),
      confidence: (map['confidence'] as num?)?.toDouble(),
      value: map['value'] as String?,
      synced: map['synced'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());
}
