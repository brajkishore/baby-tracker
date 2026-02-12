import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_event.dart';

class EventStore {
  static const String boxName = 'events_queue';

  late Box<Map> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Map>(boxName);
  }

  Future<void> addEvent(AppEvent event) async {
    await _box.put(event.eventId, event.toMap());
  }

  List<AppEvent> getAllEvents() {
    return _box.values.map((e) => AppEvent.fromMap(e)).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<AppEvent> unsyncedByPriority(EventPriority priority) {
    final list = _box.values
        .map((e) => AppEvent.fromMap(e))
        .where((e) => !e.synced && e.priority == priority)
        .toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  Future<void> markSynced(String eventId) async {
    final map = _box.get(eventId);
    if (map == null) return;
    map['synced'] = true;
    await _box.put(eventId, map);
  }

  Future<void> deleteSynced() async {
    final keys = _box.keys.where((key) {
      final value = _box.get(key);
      return value?['synced'] == true;
    }).toList();
    await _box.deleteAll(keys);
  }
}
