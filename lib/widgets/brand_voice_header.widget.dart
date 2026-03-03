// brand_voice_header.dart
import 'package:flutter/material.dart';

class BrandVoiceHeader extends StatelessWidget {
  const BrandVoiceHeader({
    super.key,
    this.title = 'Help Us Sound Like You',
    this.subtitle =
        'Personalize your experience with Realtor OS so we can create content and reach out on your behalf that matches your unique brand and voice.',
    this.currentStep = 1,
    this.totalSteps = 5,
    this.onSkip,
    this.showSkip = true,
    this.padding,
  });

  final String title;
  final String subtitle;

  /// Progress indicator (e.g., step 1 of 5)
  final int currentStep;
  final int totalSteps;

  /// Skip action callback (optional)
  final VoidCallback? onSkip;
  final bool showSkip;

  /// Optional outer padding
  final EdgeInsets? padding;

  double _clampProgress(int step, int total) {
    if (total <= 0) return 0;
    final v = step / total;
    if (v.isNaN) return 0;
    return v.clamp(0.0, 1.0);
  }

  String _progressLabel(int step, int total) {
    final s = step.clamp(0, total <= 0 ? 0 : total);
    return total <= 0 ? '' : 'Step $s of $total';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final progress = _clampProgress(currentStep, totalSteps);
    final label = _progressLabel(currentStep, totalSteps);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: padding ??
            const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              12,
            ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 420;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showSkip && onSkip != null) ...[
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: onSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: cs.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          minimumSize: const Size(0, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Skip'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: cs.surfaceContainerHighest,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(cs.primary),
                        ),
                      ),
                    ),
                    if (!isNarrow && label.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.textTheme.labelMedium?.color
                              ?.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isNarrow && label.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color:
                          theme.textTheme.labelMedium?.color?.withOpacity(0.75),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
