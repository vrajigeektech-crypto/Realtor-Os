import 'package:flutter/material.dart';

/// VoiceSampleCard
/// Purpose: Capture speaking style for AI voice matching
///
/// UX Copy:
/// Title: Your Voice Sample
/// Description: Record a short sample so we can match your speaking style.
/// CTA: Record Voice Sample
///
/// Notes:
/// - UI-only widget; does not call RPC directly.
/// - Hook `onRecordPressed` to your recorder flow (permission + recording + upload).
class VoiceSampleCard extends StatelessWidget {
  const VoiceSampleCard({
    super.key,
    this.title = 'Your Voice Sample',
    this.description = 'Record a short sample so we can match your speaking style.',
    this.ctaLabel = 'Record Voice Sample',
    required this.onRecordPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.trailing,
    this.padding,
  });

  final String title;
  final String description;
  final String ctaLabel;

  /// Called when the user taps the CTA.
  final VoidCallback onRecordPressed;

  /// Disables the CTA when false.
  final bool isEnabled;

  /// Shows a small progress indicator in the CTA when true.
  final bool isLoading;

  /// Optional widget on the right side of the header row (e.g., status badge).
  final Widget? trailing;

  /// Optional override for card padding.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: effectivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderRow(
              title: title,
              trailing: trailing,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.80),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: _RecordButton(
                label: ctaLabel,
                onPressed: (isEnabled && !isLoading) ? onRecordPressed : null,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.mic_rounded),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
