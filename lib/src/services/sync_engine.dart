import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/app_event.dart';
import '../storage/event_store.dart';
import 'api_service.dart';

class SyncEngine {
  SyncEngine({required EventStore store, required ApiService apiService})
      : _store = store,
        _apiService = apiService;

  final EventStore _store;
  final ApiService _apiService;

  Future<bool> syncAllPending() async {
    final online = await _isOnline();
    if (!online) return false;

    final priorities = [EventPriority.high, EventPriority.medium, EventPriority.low];

    for (final priority in priorities) {
      final events = _store.unsyncedByPriority(priority);
      for (final event in events) {
        final ok = await _apiService.sendEvent(event);
        if (ok) {
          await _store.markSynced(event.eventId);
        }
      }
    }

    return true;
  }

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
