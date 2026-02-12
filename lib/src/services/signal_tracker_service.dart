import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:geolocator/geolocator.dart';

import '../models/app_event.dart';
import '../models/status_snapshot.dart';
import 'device_service.dart';
import 'screen_state_service.dart';

class SignalTrackerService {
  SignalTrackerService({
    required DeviceService deviceService,
    required ScreenStateService screenStateService,
  })  : _deviceService = deviceService,
        _screenStateService = screenStateService;

  final DeviceService _deviceService;
  final ScreenStateService _screenStateService;
  final _battery = Battery();
  final _connectivity = Connectivity();

  final _controller = StreamController<AppEvent>.broadcast();
  Stream<AppEvent> get eventStream => _controller.stream;

  StatusSnapshot _snapshot = const StatusSnapshot();
  Timer? _heartbeat;
  String _deviceId = 'unknown-device';

  Future<void> initialize() async {
    _deviceId = await _deviceService.getOrCreateDeviceId();
    await _configureBackgroundGeolocation();
    await _emitBattery();

    _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      final type = results.isEmpty ? 'none' : results.first.name;
      _snapshot = _snapshot.copyWith(networkType: online ? type : 'offline');
      _addEvent(
        eventType: online ? EventType.networkStatus : EventType.networkLost,
        priority: online ? EventPriority.low : EventPriority.high,
        value: online ? 'online' : 'offline',
      );
    });

    _battery.onBatteryStateChanged.listen((state) async {
      final level = await _battery.batteryLevel;
      final charging = state == BatteryState.charging;
      _snapshot = _snapshot.copyWith(batteryPct: level, isCharging: charging);
      _addEvent(
        eventType: level <= 15 ? EventType.batteryLow : EventType.batteryStatus,
        priority: level <= 15 ? EventPriority.high : EventPriority.low,
        value: 'battery=$level',
      );
    });

    _screenStateService.stateStream.listen((state) {
      _snapshot = _snapshot.copyWith(screenState: state);
      _addEvent(
        eventType: EventType.screenState,
        priority: EventPriority.low,
        value: state,
      );
    });

    _heartbeat = Timer.periodic(const Duration(minutes: 1), (_) {
      _addEvent(
        eventType: EventType.heartbeat,
        priority: EventPriority.low,
        value: 'alive',
      );
    });
  }

  StatusSnapshot get snapshot => _snapshot;

  Future<void> _configureBackgroundGeolocation() async {
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      _snapshot = _snapshot.copyWith(
        lat: location.coords.latitude,
        lng: location.coords.longitude,
        accuracy: location.coords.accuracy,
        speed: location.coords.speed,
      );
      _addEvent(
        eventType: EventType.locationUpdate,
        priority: EventPriority.medium,
        value: 'accuracy=${location.coords.accuracy}',
      );
    });

    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      final moving = location.isMoving;
      _snapshot = _snapshot.copyWith(motionState: moving ? 'moving' : 'still');
      _addEvent(
        eventType: EventType.motionState,
        priority: EventPriority.medium,
        value: moving ? 'moving' : 'still',
      );

      if (_snapshot.screenState == 'OFF' && moving) {
        _addEvent(
          eventType: EventType.screenOffMoving,
          priority: EventPriority.high,
          value: 'screen_off_and_moving',
        );
      }
    });

    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) {
      final enter = event.action == 'ENTER';
      _snapshot = _snapshot.copyWith(geofenceState: enter ? 'inside' : 'outside');
      _addEvent(
        eventType: enter ? EventType.locationUpdate : EventType.geofenceExit,
        priority: enter ? EventPriority.low : EventPriority.high,
        value: '${event.identifier}:${event.action}',
      );
    });

    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      if (!event.enabled) {
        _addEvent(
          eventType: EventType.gpsDisabled,
          priority: EventPriority.high,
          value: 'gps_disabled',
        );
      }
    });

    await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 10.0,
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
      foregroundService: true,
      debug: true,
      heartbeatInterval: 60,
      geofenceInitialTriggerEntry: true,
      notification: bg.Notification(
        title: 'Baby Tracker Active',
        text: 'Monitoring safety signals in background',
        channelName: 'Baby Tracker Service',
      ),
    ));

    await bg.BackgroundGeolocation.start();
    await bg.BackgroundGeolocation.startGeofences();
  }

  Future<void> _emitBattery() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    _snapshot = _snapshot.copyWith(
      batteryPct: level,
      isCharging: state == BatteryState.charging,
    );
  }

  Future<void> captureTamperIfPermissionRevoked() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      _addEvent(
        eventType: EventType.permissionRevoked,
        priority: EventPriority.high,
        value: 'location_permission_or_service_revoked',
      );
    }
  }

  void reportMotionAnomaly({required String type, double confidence = 0.8}) {
    final eventType = type == 'drop'
        ? EventType.motionPossibleDrop
        : EventType.motionSuddenJerk;
    _addEvent(
      eventType: eventType,
      priority: EventPriority.high,
      value: type,
      confidence: confidence,
    );
  }

  void _addEvent({
    required EventType eventType,
    required EventPriority priority,
    required String value,
    double? confidence,
  }) {
    _controller.add(
      AppEvent(
        eventId: '${DateTime.now().microsecondsSinceEpoch}-$eventType',
        deviceId: _deviceId,
        eventType: eventType,
        priority: priority,
        timestamp: DateTime.now().toUtc(),
        lat: _snapshot.lat,
        lng: _snapshot.lng,
        batteryPct: _snapshot.batteryPct,
        isCharging: _snapshot.isCharging,
        networkType: _snapshot.networkType,
        screenState: _snapshot.screenState,
        motionState: _snapshot.motionState,
        speed: _snapshot.speed,
        confidence: confidence ?? _snapshot.confidence,
        value: value,
      ),
    );
  }

  void dispose() {
    _heartbeat?.cancel();
    _controller.close();
  }
}
