// onboarding_progress_bar.dart
import 'package:flutter/material.dart';
import 'dart:ui';

class OnboardingProgressBar extends StatelessWidget {
  /// progress is 0.0 - 1.0
  final double progress;

  /// Optional label shown above the bar (ex: "Profile Setup")
  final String? label;

  /// Show percentage text (ex: 72%)
  final bool showPercent;

  /// Height of the progress bar
  final double height;

  /// Optional color overrides
  final Color? trackColor;
  final Color? fillColor;

  /// Rounded corners
  final BorderRadius borderRadius;

  /// Animation settings
  final Duration animationDuration;
  final Curve animationCurve;

  const OnboardingProgressBar({
    super.key,
    required this.progress,
    this.label,
    this.showPercent = true,
    this.height = 10,
    this.trackColor,
    this.fillColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.animationDuration = const Duration(milliseconds: 450),
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentText = '${(clampedProgress * 100).round()}%';

    final resolvedTrackColor =
        trackColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.6);
    final resolvedFillColor =
        fillColor ?? theme.colorScheme.primary;

    return Semantics(
      label: 'Onboarding progress',
      value: percentText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null || showPercent)
            Row(
              children: [
                if (label != null)
                  Expanded(
                    child: Text(
                      label!,
                      style: theme.textTheme.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (showPercent)
                  Text(
                    percentText,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
            ),
          if (label != null || showPercent) const SizedBox(height: 8),
          ClipRRect(
            borderRadius: borderRadius,
            child: Container(
              height: height,
              color: resolvedTrackColor,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: clampedProgress),
                    duration: animationDuration,
                    curve: animationCurve,
                    builder: (context, value, _) {
                      return FractionallySizedBox(
                        widthFactor: value,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          color: resolvedFillColor,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
