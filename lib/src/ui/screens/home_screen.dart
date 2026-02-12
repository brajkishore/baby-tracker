import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../widgets/status_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final snapshot = appState.snapshot;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        StatusTile(
          title: 'Location',
          value: '${snapshot.lat ?? '-'}, ${snapshot.lng ?? '-'} (±${snapshot.accuracy ?? '-'}m)',
          icon: Icons.location_on,
        ),
        StatusTile(
          title: 'Battery',
          value: '${snapshot.batteryPct ?? '-'}% | Charging: ${snapshot.isCharging ?? false}',
          icon: Icons.battery_std,
        ),
        StatusTile(
          title: 'Network',
          value: snapshot.networkType,
          icon: Icons.network_check,
        ),
        StatusTile(
          title: 'Geofence',
          value: snapshot.geofenceState,
          icon: Icons.fence,
        ),
        StatusTile(
          title: 'Screen',
          value: snapshot.screenState,
          icon: Icons.phone_android,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: appState.syncing ? null : appState.syncNow,
          icon: appState.syncing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync),
          label: const Text('Sync now'),
        ),
      ],
    );
  }
}
