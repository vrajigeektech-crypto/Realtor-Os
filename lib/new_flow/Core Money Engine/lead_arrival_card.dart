import 'package:flutter/material.dart';

import 'lead_arrival_model.dart';
import 'lead_arrival_header.dart';
import 'lead_arrival_details.dart';
import 'speed_to_lead_primary_cta.dart';
import 'speed_to_lead_secondary_cta.dart';

class LeadArrivalCard extends StatelessWidget {
  const LeadArrivalCard({
    super.key,
    required this.isLoading,
    required this.lead,
    required this.primaryCtaLabel,
    required this.secondaryCtaLabel,
    required this.primaryEnabled,
    required this.secondaryEnabled,
    this.onPrimaryTap,
    this.onSecondaryTap,
  });

  final bool isLoading;
  final LeadArrivalModel? lead;

  final String primaryCtaLabel;
  final String secondaryCtaLabel;
  final bool primaryEnabled;
  final bool secondaryEnabled;

  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (lead == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: Text(
          'No recent lead detected.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LeadArrivalHeader(
              name: lead!.name,
              receivedAtLabel: lead!.receivedAtLabel,
            ),
            const SizedBox(height: 10),
            LeadArrivalDetails(
              source: lead!.source,
              phone: lead!.phone,
              email: lead!.email,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SpeedToLeadPrimaryCta(
                    label: primaryCtaLabel,
                    enabled: primaryEnabled,
                    onPressed: onPrimaryTap,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SpeedToLeadSecondaryCta(
                    label: secondaryCtaLabel,
                    enabled: secondaryEnabled,
                    onPressed: onSecondaryTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
