import 'package:flutter/material.dart';

class SpeedToLeadMetricValue extends StatelessWidget {
  const SpeedToLeadMetricValue({
    super.key,
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      value,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
