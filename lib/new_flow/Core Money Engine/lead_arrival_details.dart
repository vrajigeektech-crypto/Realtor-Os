import 'package:flutter/material.dart';

class LeadArrivalDetails extends StatelessWidget {
  const LeadArrivalDetails({
    super.key,
    required this.source,
    required this.phone,
    required this.email,
  });

  final String source;
  final String phone;
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'Source', value: source, muted: muted),
        const SizedBox(height: 6),
        _DetailRow(label: 'Phone', value: phone, muted: muted),
        const SizedBox(height: 6),
        _DetailRow(label: 'Email', value: email, muted: muted),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.muted,
  });

  final String label;
  final String value;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
