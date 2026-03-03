import 'package:flutter/material.dart';

import 'speed_to_lead_header.dart';
import 'speed_to_lead_metrics_row.dart';
import 'lead_arrival_card.dart';
import 'speed_to_lead_state_model.dart';
import 'screen_footer_compliance.dart';

class SpeedToLeadActivationScreen extends StatelessWidget {
  const SpeedToLeadActivationScreen({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onPrimaryCta,
    required this.onSecondaryCta,
  });

  final SpeedToLeadStateModel state;
  final Future<void> Function() onRefresh;
  final void Function(String leadId) onPrimaryCta;
  final void Function(String leadId) onSecondaryCta;

  static const double _tabletBp = 600;
  static const double _desktopBp = 1024;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final isTablet = w >= _tabletBp && w < _desktopBp;
            final isDesktop = w >= _desktopBp;

            final horizontalPadding = isDesktop
                ? 24.0
                : isTablet
                    ? 18.0
                    : 14.0;

            final maxContentWidth = isDesktop ? 1100.0 : double.infinity;

            return RefreshIndicator(
              onRefresh: onRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            18,
                            horizontalPadding,
                            0,
                          ),
                          child: SpeedToLeadHeader(
                            title: state.title,
                            subtitle: state.subtitle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            16,
                            horizontalPadding,
                            0,
                          ),
                          child: SpeedToLeadMetricsRow(
                            metrics: state.metrics,
                            isLoading: state.isLoading,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            18,
                            horizontalPadding,
                            0,
                          ),
                          child: LeadArrivalCard(
                            isLoading: state.isLoading,
                            lead: state.latestLead,
                            primaryCtaLabel: state.primaryCtaLabel,
                            secondaryCtaLabel: state.secondaryCtaLabel,
                            primaryEnabled: state.primaryEnabled,
                            secondaryEnabled: state.secondaryEnabled,
                            onPrimaryTap: state.latestLead == null
                                ? null
                                : () => onPrimaryCta(state.latestLead!.leadId),
                            onSecondaryTap: state.latestLead == null
                                ? null
                                : () =>
                                    onSecondaryCta(state.latestLead!.leadId),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            18,
                            horizontalPadding,
                            16,
                          ),
                          child: Text(
                            state.bottomNote,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            12,
                            horizontalPadding,
                            16,
                          ),
                          child: const Align(
                            alignment: Alignment.bottomCenter,
                            child: ScreenFooterCompliance(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
