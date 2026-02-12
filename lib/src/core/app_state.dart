import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../models/app_event.dart';
import '../models/status_snapshot.dart';
import '../repositories/tracker_repository.dart';
import '../services/background_tasks.dart';
import '../services/permissions_service.dart';
import '../services/signal_tracker_service.dart';
import '../services/sync_engine.dart';

class AppState extends ChangeNotifier {
  AppState({
    required TrackerRepository trackerRepository,
    required SignalTrackerService signalTrackerService,
    required SyncEngine syncEngine,
    required PermissionsService permissionsService,
    required String apiBaseUrl,
  })  : _trackerRepository = trackerRepository,
        _signalTrackerService = signalTrackerService,
        _syncEngine = syncEngine,
        _permissionsService = permissionsService,
        _apiBaseUrl = apiBaseUrl;

  final TrackerRepository _trackerRepository;
  final SignalTrackerService _signalTrackerService;
  final SyncEngine _syncEngine;
  final PermissionsService _permissionsService;
  final String _apiBaseUrl;

  PermissionsState? permissionsState;
  EventPriority selectedPriority = EventPriority.high;
  bool syncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  Future<void> init() async {
    permissionsState = await _permissionsService.check();
    await _trackerRepository.initialize();

    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    await Workmanager().registerPeriodicTask(
      syncTaskName,
      syncTaskName,
      frequency: const Duration(minutes: 15),
      inputData: {'baseUrl': _apiBaseUrl},
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((e) => e != ConnectivityResult.none);
      if (online) {
        syncNow();
      }
    });

    notifyListeners();
  }

  List<AppEvent> get logs {
    final all = _trackerRepository.events;
    return all.where((e) => e.priority == selectedPriority).toList();
  }

  StatusSnapshot get snapshot => _signalTrackerService.snapshot;

  Future<void> requestPermissions() async {
    permissionsState = await _permissionsService.requestAll();
    await _signalTrackerService.captureTamperIfPermissionRevoked();
    notifyListeners();
  }

  void setFilter(EventPriority priority) {
    selectedPriority = priority;
    notifyListeners();
  }

  Future<void> syncNow() async {
    syncing = true;
    notifyListeners();
    await _syncEngine.syncAllPending();
    syncing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _trackerRepository.dispose();
    super.dispose();
  }
}
