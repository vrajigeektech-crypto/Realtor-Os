import 'package:flutter/material.dart';

import 'speed_to_lead_metric_key.dart';

class SpeedToLeadMetricIcon extends StatelessWidget {
  const SpeedToLeadMetricIcon({
    super.key,
    required this.metricKey,
  });

  final SpeedToLeadMetricKey metricKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.surfaceVariant,
      ),
      child: Icon(
        _iconForKey(metricKey),
        size: 18,
        color: cs.onSurfaceVariant,
      ),
    );
  }

  IconData _iconForKey(SpeedToLeadMetricKey key) {
    switch (key) {
      case SpeedToLeadMetricKey.responseTime:
        return Icons.timer_outlined;
      case SpeedToLeadMetricKey.firstContact:
        return Icons.phone_in_talk_outlined;
      case SpeedToLeadMetricKey.bpaSent:
        return Icons.send_outlined;
      case SpeedToLeadMetricKey.bpaSigned:
        return Icons.assignment_turned_in_outlined;
      case SpeedToLeadMetricKey.conversion:
        return Icons.trending_up_outlined;
    }
  }
}
