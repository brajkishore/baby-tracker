import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../models/app_event.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final events = appState.logs;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<EventPriority>(
            segments: const [
              ButtonSegment(value: EventPriority.high, label: Text('HIGH')),
              ButtonSegment(value: EventPriority.medium, label: Text('MEDIUM')),
              ButtonSegment(value: EventPriority.low, label: Text('LOW')),
            ],
            selected: {appState.selectedPriority},
            onSelectionChanged: (selection) {
              appState.setFilter(selection.first);
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                leading: Icon(
                  event.synced ? Icons.cloud_done : Icons.cloud_upload,
                  color: event.synced ? Colors.green : Colors.orange,
                ),
                title: Text(event.eventType.name),
                subtitle: Text(
                  '${DateFormat('y-MM-dd HH:mm:ss').format(event.timestamp.toLocal())}\n${event.value ?? ''}',
                ),
                isThreeLine: true,
              );
            },
          ),
        ),
      ],
    );
  }
}
