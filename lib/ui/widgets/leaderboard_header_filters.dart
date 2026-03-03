// leaderboard_header_filters.dart
import 'package:flutter/material.dart';

import '../../models/leaderboard_filter_model.dart';

class LeaderboardHeaderFilters extends StatelessWidget {
  const LeaderboardHeaderFilters({
    super.key,
    required this.filters,
    required this.onChanged,
    this.availablePeriods = const [],
    this.availableTeams = const [],
    this.availableActivities = const [],
  });

  final LeaderboardFilters filters;
  final ValueChanged<LeaderboardFilters> onChanged;

  /// Optional (host can supply from RPC later). If empty, fall back to defaults.
  final List<LeaderboardPeriodOption> availablePeriods;
  final List<LeaderboardTeamOption> availableTeams;
  final List<LeaderboardActivityOption> availableActivities;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final periods = availablePeriods.isNotEmpty
        ? availablePeriods
        : LeaderboardPeriodOption.defaults();
    final teams = availableTeams.isNotEmpty
        ? availableTeams
        : LeaderboardTeamOption.defaults();
    final activities = availableActivities.isNotEmpty
        ? availableActivities
        : LeaderboardActivityOption.defaults();

    final selectedPeriod = periods.firstWhere(
      (p) => p.key == filters.periodKey,
      orElse: () => periods.first,
    );
    final selectedTeam = teams.firstWhere(
      (p) => p.id == filters.teamId,
      orElse: () => teams.first,
    );
    final selectedActivity = activities.firstWhere(
      (p) => p.key == filters.activityKey,
      orElse: () => activities.first,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        final bool isWide = w >= 900;
        final bool isMedium = w >= 640;

        final double gap = isWide ? 18 : 12;

        final children = <Widget>[
          _FilterField<LeaderboardPeriodOption>(
            label: 'Time Period:',
            value: selectedPeriod,
            items: periods,
            itemLabel: (x) => x.label,
            onChanged: (next) {
              if (next == null) return;
              onChanged(filters.copyWith(periodKey: next.key));
            },
          ),
          _FilterField<LeaderboardTeamOption>(
            label: 'Team',
            value: selectedTeam,
            items: teams,
            itemLabel: (x) => x.label,
            onChanged: (next) {
              if (next == null) return;
              onChanged(filters.copyWith(teamId: next.id));
            },
          ),
          _FilterField<LeaderboardActivityOption>(
            label: 'Activity',
            value: selectedActivity,
            items: activities,
            itemLabel: (x) => x.label,
            onChanged: (next) {
              if (next == null) return;
              onChanged(filters.copyWith(activityKey: next.key));
            },
          ),
        ];

        final Widget content = isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: children[0]),
                  SizedBox(width: gap),
                  Expanded(child: children[1]),
                  SizedBox(width: gap),
                  Expanded(child: children[2]),
                ],
              )
            : isMedium
                ? Wrap(
                    spacing: gap,
                    runSpacing: 12,
                    children: [
                      SizedBox(width: (w - gap) / 2, child: children[0]),
                      SizedBox(width: (w - gap) / 2, child: children[1]),
                      SizedBox(width: w, child: children[2]),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      children[0],
                      const SizedBox(height: 12),
                      children[1],
                      const SizedBox(height: 12),
                      children[2],
                    ],
                  );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              height: 1,
              thickness: 1,
              color: cs.outlineVariant.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 14),
            DefaultTextStyle(
              style: t.bodyMedium ?? const TextStyle(),
              child: content,
            ),
          ],
        );
      },
    );
  }
}

class _FilterField<T> extends StatelessWidget {
  const _FilterField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: (t.labelLarge ?? const TextStyle()).copyWith(
            color: cs.onSurface.withValues(alpha: 0.78),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        _DropdownShell(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: cs.onSurface.withValues(alpha: 0.75),
              ),
              dropdownColor: cs.surface,
              borderRadius: BorderRadius.circular(12),
              items: items
                  .map(
                    (it) => DropdownMenuItem<T>(
                      value: it,
                      child: Text(
                        itemLabel(it),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (t.titleMedium ?? const TextStyle()).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownShell extends StatelessWidget {
  const _DropdownShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
