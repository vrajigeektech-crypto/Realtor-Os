import 'package:flutter/material.dart';

class IntegrationStatusBadge extends StatelessWidget {
  final bool connected;

  const IntegrationStatusBadge({
    super.key,
    required this.connected,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = connected ? Colors.green : Colors.grey;
    final String label = connected ? 'Connected' : 'Not Connected';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
