import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'src/core/app_state.dart';
import 'src/repositories/tracker_repository.dart';
import 'src/services/api_service.dart';
import 'src/services/background_tasks.dart';
import 'src/services/device_service.dart';
import 'src/services/permissions_service.dart';
import 'src/services/screen_state_service.dart';
import 'src/services/signal_tracker_service.dart';
import 'src/services/sync_engine.dart';
import 'src/storage/event_store.dart';
import 'src/ui/app.dart';

const apiBaseUrl = 'https://replace-me.example.com';

@pragma('vm:entry-point')
void headlessTask(bg.HeadlessEvent headlessEvent) async {
  // Captures geolocation events while app is terminated.
  // You can expand this to persist events in dedicated headless storage handlers.
  debugPrint('Headless event: ${headlessEvent.name}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bg.BackgroundGeolocation.registerHeadlessTask(headlessTask);

  await Hive.initFlutter();
  final eventStore = EventStore();
  await eventStore.init();

  final deviceService = DeviceService();
  final signalTrackerService = SignalTrackerService(
    deviceService: deviceService,
    screenStateService: ScreenStateService(),
  );
  final repository = TrackerRepository(
    signalTrackerService: signalTrackerService,
    eventStore: eventStore,
  );
  final syncEngine = SyncEngine(
    store: eventStore,
    apiService: ApiService(baseUrl: apiBaseUrl),
  );

  final appState = AppState(
    trackerRepository: repository,
    signalTrackerService: signalTrackerService,
    syncEngine: syncEngine,
    permissionsService: PermissionsService(),
    apiBaseUrl: apiBaseUrl,
  );

  await appState.init();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const BabyTrackerRoot(),
    ),
  );
}

class BabyTrackerRoot extends StatelessWidget {
  const BabyTrackerRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Tracker',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const BabyTrackerAppShell(),
    );
  }
}
