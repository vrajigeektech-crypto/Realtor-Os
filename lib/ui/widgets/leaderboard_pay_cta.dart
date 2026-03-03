// leaderboard_pay_cta.dart
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class LeaderboardPayCta extends StatelessWidget {
  const LeaderboardPayCta({
    super.key,
    required this.label,
    required this.onTap,
    this.helperText = 'Pay to unlock detailed agent breakdown.',
  });

  final String label;
  final VoidCallback? onTap;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        final bool compact = w < 520;

        final EdgeInsets pad = compact
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 14);

        return Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: pad,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
                width: 1,
              ),
            ),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        helperText,
                        style: (t.bodyMedium ?? const TextStyle()).copyWith(
                          color: cs.onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PrimaryCtaButton(label: label, onTap: onTap),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          helperText,
                          style: (t.bodyMedium ?? const TextStyle()).copyWith(
                            color: cs.onSurface.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _PrimaryCtaButton(label: label, onTap: onTap),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _PrimaryCtaButton extends StatelessWidget {
  const _PrimaryCtaButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: AppColors.buttonGold,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_open_rounded,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
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
