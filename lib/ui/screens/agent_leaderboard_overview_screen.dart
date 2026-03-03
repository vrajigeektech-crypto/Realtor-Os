// agent_leaderboard_overview_screen.dart
import 'package:flutter/material.dart';

import '../widgets/leaderboard_header_filters.dart';
import '../widgets/leaderboard_pay_cta.dart';
import '../widgets/leaderboard_table.dart';
import '../../../models/leaderboard_agent_model.dart';
import '../../../models/leaderboard_filter_model.dart';
import '../widgets/leaderboard_outcome_badge.dart';

class AgentLeaderboardOverviewScreen extends StatefulWidget {
  const AgentLeaderboardOverviewScreen({
    super.key,
    required this.orgId,
    this.initialFilters,
    this.initialAgents = const [],
    this.onFiltersChanged,
    this.onAgentTap,
    this.onPayTap,
  });

  final String orgId;

  /// Provided by caller (Supabase/RPC wiring comes later).
  final LeaderboardFilters? initialFilters;
  final List<LeaderboardAgent> initialAgents;

  /// Notify host when filters change (host can refetch).
  final ValueChanged<LeaderboardFilters>? onFiltersChanged;

  /// Row click.
  final ValueChanged<LeaderboardAgent>? onAgentTap;

  /// CTA click.
  final VoidCallback? onPayTap;

  @override
  State<AgentLeaderboardOverviewScreen> createState() =>
      _AgentLeaderboardOverviewScreenState();
}

class _AgentLeaderboardOverviewScreenState
    extends State<AgentLeaderboardOverviewScreen> {
  late LeaderboardFilters _filters;
  late List<LeaderboardAgent> _agents;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters ?? LeaderboardFilters.defaults();
    // Use static data matching the image if no initial agents provided
    _agents = widget.initialAgents.isEmpty
        ? _getStaticAgentData()
        : List<LeaderboardAgent>.from(widget.initialAgents);
  }

  static List<LeaderboardAgent> _getStaticAgentData() {
    return [
      // Rank 1: Hannah Lee
      const LeaderboardAgent(
        id: '1',
        fullName: 'Hannah Lee',
        initials: 'HL',
        subLabel: 'Team Lead',
        rank: 1,
        role: 'Team Lead',
        productionVolume: '\$2.4M',
        score: 88,
        activityTrendPoints: [0.3, 0.5, 0.7, 0.6, 0.8, 0.9, 0.85],
        activityTrendColor: ActivityTrendColor.green,
        outcomeLabel: 'Highly Active',
        outcomeTone: OutcomeTone.good,
        showStars: true,
      ),
      // Rank 3: Jane Smith
      const LeaderboardAgent(
        id: '2',
        fullName: 'Jane Smith',
        initials: 'JS',
        subLabel: 'Team Lead',
        rank: 3,
        role: 'Team Lead',
        productionVolume: '\$2.1M',
        score: 73,
        activityTrendPoints: [0.4, 0.5, 0.6, 0.7, 0.75, 0.8, 0.78],
        activityTrendColor: ActivityTrendColor.green,
        outcomeLabel: 'Highly Active',
        outcomeTone: OutcomeTone.good,
        showStars: true,
      ),
      // Rank 3: Brian Johnson
      const LeaderboardAgent(
        id: '3',
        fullName: 'Brian Johnson',
        initials: 'BJ',
        subLabel: 'Broker',
        rank: 3,
        role: 'Broker',
        productionVolume: '\$1.8M',
        score: 69,
        activityTrendPoints: [0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.35],
        activityTrendColor: ActivityTrendColor.red,
        outcomeLabel: 'At Risk',
        outcomeTone: OutcomeTone.bad,
        showStars: false,
      ),
      // Rank 4: John Doe
      const LeaderboardAgent(
        id: '4',
        fullName: 'John Doe',
        initials: 'JD',
        subLabel: 'Agent',
        rank: 4,
        role: 'Agent',
        productionVolume: '\$1.5M',
        score: 76,
        activityTrendPoints: [0.3, 0.4, 0.5, 0.6, 0.7, 0.75, 0.8],
        activityTrendColor: ActivityTrendColor.green,
        outcomeLabel: 'Highly Active',
        outcomeTone: OutcomeTone.good,
        showStars: true,
      ),
      // Rank 5: Katie Taylor
      const LeaderboardAgent(
        id: '5',
        fullName: 'Katie Taylor',
        initials: 'KT',
        subLabel: 'Gooni',
        rank: 5,
        role: 'Agent',
        productionVolume: '\$1.3M',
        score: 54,
        activityTrendPoints: [0.5, 0.55, 0.5, 0.6, 0.55, 0.6, 0.58],
        activityTrendColor: ActivityTrendColor.blue,
        outcomeLabel: 'Underutilizing Tool',
        outcomeTone: OutcomeTone.neutral,
        showStars: false,
      ),
      // Rank 6: David Brown
      const LeaderboardAgent(
        id: '6',
        fullName: 'David Brown',
        initials: 'DB',
        subLabel: 'Agent',
        rank: 6,
        role: 'Agent',
        productionVolume: '\$967K',
        score: 51,
        activityTrendPoints: [0.2, 0.3, 0.4, 0.5, 0.6, 0.65, 0.7],
        activityTrendColor: ActivityTrendColor.green,
        outcomeLabel: 'Highly Active',
        outcomeTone: OutcomeTone.good,
        showStars: true,
      ),
      // Rank 7: Michael Garcia
      const LeaderboardAgent(
        id: '7',
        fullName: 'Michael Garcia',
        initials: 'MG',
        subLabel: 'Sonnt',
        rank: 7,
        role: 'Agent',
        productionVolume: '\$842K',
        score: 85,
        activityTrendPoints: [0.7, 0.6, 0.5, 0.4, 0.3, 0.25, 0.2],
        activityTrendColor: ActivityTrendColor.red,
        outcomeLabel: 'At Risk',
        outcomeTone: OutcomeTone.bad,
        showStars: false,
      ),
    ];
  }

  void _updateFilters(LeaderboardFilters next) {
    setState(() => _filters = next);
    widget.onFiltersChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;

            final EdgeInsets pagePadding = w >= 1200
                ? const EdgeInsets.fromLTRB(40, 28, 40, 28)
                : w >= 900
                    ? const EdgeInsets.fromLTRB(28, 24, 28, 24)
                    : const EdgeInsets.fromLTRB(16, 18, 16, 18);

            final double contentMaxWidth = w >= 1400 ? 1240 : double.infinity;

            return SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Padding(
                    padding: pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBrandRow(
                          title: 'Agent Leaderboard Overview',
                          onLogoTap: () {},
                        ),
                        const SizedBox(height: 18),
                        LeaderboardHeaderFilters(
                          filters: _filters,
                          onChanged: _updateFilters,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 600,
                          child: LeaderboardTable(
                            agents: _agents,
                            onAgentTap: widget.onAgentTap,
                          ),
                        ),
                        const SizedBox(height: 14),
                        LeaderboardPayCta(
                          label: 'Pay \$49.00',
                          onTap: widget.onPayTap,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBrandRow extends StatelessWidget {
  const _TopBrandRow({
    required this.title,
    required this.onLogoTap,
  });

  final String title;
  final VoidCallback onLogoTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: onLogoTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.radar_rounded,
              size: 24,
              color: cs.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}
