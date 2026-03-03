// leaderboard_outcome_badge.dart
import 'package:flutter/material.dart';

class LeaderboardOutcomeBadge extends StatelessWidget {
  const LeaderboardOutcomeBadge({
    super.key,
    required this.outcomeLabel,
    required this.outcomeTone,
    this.showStars = false,
    this.onTap,
  });

  final String outcomeLabel;
  final OutcomeTone outcomeTone;
  final bool showStars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final _OutcomePalette palette = _OutcomePalette.fromTone(cs, outcomeTone);

    return Material(
      color: palette.bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: palette.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showStars) ...[
                ...List.generate(3, (index) => Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                    )),
                const SizedBox(width: 6),
              ] else ...[
                Icon(
                  palette.icon,
                  size: 16,
                  color: palette.fg,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                outcomeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: palette.fg,
                      fontWeight: FontWeight.w700,
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

enum OutcomeTone { good, warning, neutral, bad }

class _OutcomePalette {
  _OutcomePalette({
    required this.bg,
    required this.border,
    required this.fg,
    required this.icon,
  });

  final Color bg;
  final Color border;
  final Color fg;
  final IconData icon;

  static _OutcomePalette fromTone(ColorScheme cs, OutcomeTone tone) {
    switch (tone) {
      case OutcomeTone.good:
        return _OutcomePalette(
          bg: cs.primary.withValues(alpha: 0.12),
          border: cs.primary.withValues(alpha: 0.55),
          fg: cs.onSurface.withValues(alpha: 0.92),
          icon: Icons.check_circle_rounded,
        );
      case OutcomeTone.warning:
        return _OutcomePalette(
          bg: cs.secondary.withValues(alpha: 0.14),
          border: cs.secondary.withValues(alpha: 0.60),
          fg: cs.onSurface.withValues(alpha: 0.92),
          icon: Icons.warning_rounded,
        );
      case OutcomeTone.bad:
        return _OutcomePalette(
          bg: cs.error.withValues(alpha: 0.12),
          border: cs.error.withValues(alpha: 0.55),
          fg: cs.onSurface.withValues(alpha: 0.92),
          icon: Icons.cancel_rounded,
        );
      case OutcomeTone.neutral:
      default:
        return _OutcomePalette(
          bg: cs.surfaceVariant.withValues(alpha: 0.55),
          border: cs.outlineVariant.withValues(alpha: 0.55),
          fg: cs.onSurface.withValues(alpha: 0.82),
          icon: Icons.info_rounded,
        );
    }
  }
}
