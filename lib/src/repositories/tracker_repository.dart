import 'dart:async';

import '../models/app_event.dart';
import '../services/signal_tracker_service.dart';
import '../storage/event_store.dart';

class TrackerRepository {
  TrackerRepository({
    required SignalTrackerService signalTrackerService,
    required EventStore eventStore,
  })  : _signalTrackerService = signalTrackerService,
        _eventStore = eventStore;

  final SignalTrackerService _signalTrackerService;
  final EventStore _eventStore;
  StreamSubscription<AppEvent>? _subscription;

  Future<void> initialize() async {
    await _signalTrackerService.initialize();
    _subscription = _signalTrackerService.eventStream.listen(_eventStore.addEvent);
  }

  List<AppEvent> get events => _eventStore.getAllEvents();

  Future<void> dispose() async {
    await _subscription?.cancel();
    _signalTrackerService.dispose();
  }
}
