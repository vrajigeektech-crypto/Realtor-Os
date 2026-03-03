import 'package:flutter/material.dart';

class ScreenFooterCompliance extends StatelessWidget {
  const ScreenFooterCompliance({
    super.key,
    this.text,
  });

  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text ??
            'Speed-to-lead actions are system-assisted and may require broker approval.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
