import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final permissions = appState.permissionsState;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Permissions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (permissions == null)
          const Text('Permission state loading...')
        else ...[
          ListTile(
            title: const Text('Location'),
            subtitle: Text(permissions.location.name),
          ),
          ListTile(
            title: const Text('Background Location'),
            subtitle: Text(permissions.backgroundLocation.name),
          ),
          ListTile(
            title: const Text('Notification'),
            subtitle: Text(permissions.notification.name),
          ),
          if (!permissions.allGranted)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Some required permissions are denied. Please grant them for reliable background tracking.',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
        ],
        const SizedBox(height: 12),
        FilledButton(
          onPressed: appState.requestPermissions,
          child: const Text('Request permissions'),
        ),
        const SizedBox(height: 20),
        const Text('Geofence zone setup', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('Configure geofences in code/backend for now. Example: home_daycare_zone radius 150m.'),
        const SizedBox(height: 16),
        const Text('Sync settings', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('Periodic sync uses WorkManager. Android runs approximately every 15 min minimum interval.'),
      ],
    );
  }
}
