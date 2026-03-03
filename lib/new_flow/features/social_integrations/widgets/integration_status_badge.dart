import 'package:flutter/material.dart';

class IntegrationStatusBadge extends StatelessWidget {
  const IntegrationStatusBadge({
    super.key,
    required this.connected,
  });

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = connected
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    final label = connected ? 'Connected' : 'Not connected';

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
