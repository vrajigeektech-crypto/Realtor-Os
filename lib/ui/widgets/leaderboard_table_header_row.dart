// leaderboard_table_header_row.dart
import 'package:flutter/material.dart';

import '../../models/leaderboard_agent_model.dart';

class LeaderboardTableHeaderRow extends StatelessWidget {
  const LeaderboardTableHeaderRow({
    super.key,
    required this.compact,
    required this.sort,
    this.onSortChanged,
  });

  final bool compact;
  final LeaderboardSort sort;
  final ValueChanged<LeaderboardSort>? onSortChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final TextStyle style = (t.labelLarge ?? const TextStyle()).copyWith(
      color: cs.onSurface.withValues(alpha: 0.78),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final bool ultraCompact = w < 560;

        return Row(
          children: [
            Expanded(
              flex: 8,
              child: _HeaderCell(
                label: 'Rank',
                style: style,
              ),
            ),
            Expanded(
              flex: 20,
              child: _HeaderCell(
                label: 'Agent',
                style: style,
              ),
            ),
            Expanded(
              flex: 12,
              child: _SortableHeaderCell(
                label: 'Role',
                style: style,
                active: sort == LeaderboardSort.role,
                onTap: onSortChanged == null
                    ? null
                    : () => onSortChanged!.call(LeaderboardSort.role),
              ),
            ),
            Expanded(
              flex: 14,
              child: _SortableHeaderCell(
                label: 'Production Volume',
                style: style,
                active: sort == LeaderboardSort.productionVolume,
                onTap: onSortChanged == null
                    ? null
                    : () => onSortChanged!.call(LeaderboardSort.productionVolume),
              ),
            ),
            Expanded(
              flex: 14,
              child: _SortableHeaderCell(
                label: 'BPA Usage Score',
                style: style,
                active: sort == LeaderboardSort.score,
                onTap: onSortChanged == null
                    ? null
                    : () => onSortChanged!.call(LeaderboardSort.score),
              ),
            ),
            if (!ultraCompact) ...[
              Expanded(
                flex: 14,
                child: _SortableHeaderCell(
                  label: 'Activity Trend',
                  style: style,
                  active: sort == LeaderboardSort.trend,
                  onTap: onSortChanged == null
                      ? null
                      : () => onSortChanged!.call(LeaderboardSort.trend),
                ),
              ),
            ],
            if (!compact) ...[
              Expanded(
                flex: 18,
                child: _SortableHeaderCell(
                  label: 'Outcome',
                  style: style,
                  active: sort == LeaderboardSort.outcome,
                  onTap: onSortChanged == null
                      ? null
                      : () => onSortChanged!.call(LeaderboardSort.outcome),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.style,
    this.trailing,
  });

  final String label;
  final TextStyle style;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

class _SortableHeaderCell extends StatelessWidget {
  const _SortableHeaderCell({
    required this.label,
    required this.style,
    required this.active,
    required this.onTap,
  });

  final String label;
  final TextStyle style;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final Color border = active
        ? cs.primary.withValues(alpha: 0.65)
        : cs.outlineVariant.withValues(alpha: 0.45);

    final Color bg =
        active ? cs.primary.withValues(alpha: 0.10) : Colors.transparent;

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.unfold_more_rounded,
                  size: 16,
                  color: cs.onSurface.withValues(alpha: 0.72),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SortPill extends StatelessWidget {
  const _SortPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: cs.onSurface.withValues(alpha: 0.75)),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
