// leaderboard_agent_row.dart
import 'package:flutter/material.dart';

import 'leaderboard_activity_trend_sparkline.dart';
import 'leaderboard_outcome_badge.dart';
import '../../models/leaderboard_agent_model.dart';

class LeaderboardAgentRow extends StatelessWidget {
  const LeaderboardAgentRow({
    super.key,
    required this.compact,
    required this.agent,
    this.onTap,
  });

  final bool compact;
  final LeaderboardAgent agent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final bool ultraCompact = w < 560;

        final EdgeInsets pad = compact
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 14);

        final nameStyle = (t.titleMedium ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        );

        final subStyle = (t.bodySmall ?? const TextStyle()).copyWith(
          color: cs.onSurface.withValues(alpha: 0.72),
          fontWeight: FontWeight.w500,
        );

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: pad,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Rank column
                  Expanded(
                    flex: 8,
                    child: _RankCell(rank: agent.rank),
                  ),
                  // Agent column (Avatar + Name + Role)
                  Expanded(
                    flex: 20,
                    child: _AgentCell(
                      agent: agent,
                      nameStyle: nameStyle,
                      subStyle: subStyle,
                    ),
                  ),
                  // Role column
                  Expanded(
                    flex: 12,
                    child: _RoleCell(role: agent.role),
                  ),
                  // Production Volume column
                  Expanded(
                    flex: 14,
                    child: _ProductionVolumeCell(volume: agent.productionVolume),
                  ),
                  // BPA Usage Score column
                  Expanded(
                    flex: 14,
                    child: _BpaScoreCell(score: agent.score),
                  ),
                  // Activity Trend column
                  if (!ultraCompact) ...[
                    Expanded(
                      flex: 14,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: LeaderboardActivityTrendSparkline(
                          points: agent.activityTrendPoints,
                          trendColor: agent.activityTrendColor,
                          compact: compact,
                          onTap: onTap,
                        ),
                      ),
                    ),
                  ],
                  // Outcome column
                  if (!compact) ...[
                    Expanded(
                      flex: 18,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: LeaderboardOutcomeBadge(
                          outcomeLabel: agent.outcomeLabel,
                          outcomeTone: agent.outcomeTone,
                          showStars: agent.showStars,
                          onTap: onTap,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RankCell extends StatelessWidget {
  const _RankCell({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Text(
      rank.toString(),
      style: (t.titleMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
    );
  }
}

class _AgentCell extends StatelessWidget {
  const _AgentCell({
    required this.agent,
    required this.nameStyle,
    required this.subStyle,
  });

  final LeaderboardAgent agent;
  final TextStyle nameStyle;
  final TextStyle subStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(
          initials: agent.initials,
          onTap: () {},
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agent.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: nameStyle,
              ),
              const SizedBox(height: 4),
              Text(
                agent.subLabel.isNotEmpty ? agent.subLabel : agent.role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: subStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleCell extends StatelessWidget {
  const _RoleCell({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Text(
      role,
      style: (t.bodyMedium ?? const TextStyle()).copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ProductionVolumeCell extends StatelessWidget {
  const _ProductionVolumeCell({required this.volume});

  final String volume;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Text(
      volume,
      style: (t.bodyMedium ?? const TextStyle()).copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _BpaScoreCell extends StatelessWidget {
  const _BpaScoreCell({required this.score});

  final num score;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          score.toString(),
          style: (t.bodyMedium ?? const TextStyle()).copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          Icons.check_circle,
          size: 16,
          color: Colors.green,
        ),
      ],
    );
  }
}


class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.onTap,
  });

  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Text(
            initials,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
        ),
      ),
    );
  }
}

