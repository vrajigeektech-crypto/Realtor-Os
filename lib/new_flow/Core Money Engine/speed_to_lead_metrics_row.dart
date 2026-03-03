import 'package:flutter/material.dart';

import 'speed_to_lead_metric_card.dart';
import 'speed_to_lead_metric_model.dart';

class SpeedToLeadMetricsRow extends StatelessWidget {
  const SpeedToLeadMetricsRow({
    super.key,
    required this.metrics,
    required this.isLoading,
  });

  final List<SpeedToLeadMetricModel> metrics;
  final bool isLoading;

  static const double _tabletBp = 600;
  static const double _desktopBp = 1024;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final columns = w >= _desktopBp
            ? 5
            : w >= _tabletBp
                ? 3
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            return SpeedToLeadMetricCard(metric: metrics[index]);
          },
        );
      },
    );
  }
}
