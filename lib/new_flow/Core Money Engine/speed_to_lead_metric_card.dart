import 'package:flutter/material.dart';

import 'speed_to_lead_metric_model.dart';
import 'speed_to_lead_metric_icon.dart';
import 'speed_to_lead_metric_label.dart';
import 'speed_to_lead_metric_value.dart';

class SpeedToLeadMetricCard extends StatelessWidget {
  const SpeedToLeadMetricCard({
    super.key,
    required this.metric,
  });

  final SpeedToLeadMetricModel metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpeedToLeadMetricIcon(metricKey: metric.metricKey),
          const SizedBox(height: 10),
          SpeedToLeadMetricValue(value: metric.value),
          const SizedBox(height: 6),
          SpeedToLeadMetricLabel(label: metric.label),
        ],
      ),
    );
  }
}
