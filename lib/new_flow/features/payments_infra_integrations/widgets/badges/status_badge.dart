import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final bool connected;

  const StatusBadge({
    super.key,
    required this.connected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color color =
        connected ? theme.colorScheme.primary : theme.colorScheme.error;

    final String label = connected ? 'Connected' : 'Not connected';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
