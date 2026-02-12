import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../storage/event_store.dart';
import 'api_service.dart';
import 'sync_engine.dart';

const syncTaskName = 'baby_tracker_sync';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    final store = EventStore();
    await store.init();

    final baseUrl = inputData?['baseUrl'] as String? ?? 'https://replace-me.example.com';
    final engine = SyncEngine(
      store: store,
      apiService: ApiService(baseUrl: baseUrl),
    );

    await engine.syncAllPending();
    return Future.value(true);
  });
}
