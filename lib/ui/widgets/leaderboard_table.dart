// leaderboard_table.dart
import 'package:flutter/material.dart';

import 'leaderboard_agent_row.dart';
import 'leaderboard_table_header_row.dart';
import '../../models/leaderboard_agent_model.dart';

class LeaderboardTable extends StatelessWidget {
  const LeaderboardTable({
    super.key,
    required this.agents,
    this.onAgentTap,
    this.onSortChanged,
    this.initialSort = LeaderboardSort.rank,
  });

  final List<LeaderboardAgent> agents;
  final ValueChanged<LeaderboardAgent>? onAgentTap;

  /// Host can respond to sort change by reordering/refetching.
  final ValueChanged<LeaderboardSort>? onSortChanged;

  final LeaderboardSort initialSort;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        final bool compact = w < 720;
        final bool comfy = w >= 1100;

        final EdgeInsets padding = comfy
            ? const EdgeInsets.all(18)
            : compact
                ? const EdgeInsets.all(12)
                : const EdgeInsets.all(14);

        return _TableShell(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LeaderboardTableHeaderRow(
                compact: compact,
                sort: initialSort,
                onSortChanged: onSortChanged,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _ScrollableList(
                  compact: compact,
                  agents: agents,
                  onAgentTap: onAgentTap,
                ),
              ),
              const SizedBox(height: 10),
              Divider(
                height: 1,
                thickness: 1,
                color: cs.outlineVariant.withValues(alpha: 0.35),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScrollableList extends StatelessWidget {
  const _ScrollableList({
    required this.compact,
    required this.agents,
    required this.onAgentTap,
  });

  final bool compact;
  final List<LeaderboardAgent> agents;
  final ValueChanged<LeaderboardAgent>? onAgentTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (agents.isEmpty) {
      return Center(
        child: Text(
          'No agents found for this selection.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.72),
              ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Scrollbar(
      thumbVisibility: true,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: agents.length,
        separatorBuilder: (context, i) => Divider(
          height: 1,
          thickness: 1,
          color: cs.outlineVariant.withValues(alpha: 0.25),
        ),
        itemBuilder: (context, index) {
          final a = agents[index];
          return LeaderboardAgentRow(
            compact: compact,
            agent: a,
            onTap: onAgentTap == null ? null : () => onAgentTap!.call(a),
          );
        },
      ),
    );
  }
}

class _TableShell extends StatelessWidget {
  const _TableShell({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
