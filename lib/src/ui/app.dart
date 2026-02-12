import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/logs_screen.dart';
import 'screens/settings_screen.dart';

class BabyTrackerAppShell extends StatefulWidget {
  const BabyTrackerAppShell({super.key});

  @override
  State<BabyTrackerAppShell> createState() => _BabyTrackerAppShellState();
}

class _BabyTrackerAppShellState extends State<BabyTrackerAppShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    LogsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baby Tracker')),
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Logs'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
