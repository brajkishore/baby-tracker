import 'package:flutter/material.dart';

class StatusTile extends StatelessWidget {
  const StatusTile({
    super.key,
    required this.title,
    required this.value,
    this.icon,
  });

  final String title;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: icon != null ? Icon(icon) : null,
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
