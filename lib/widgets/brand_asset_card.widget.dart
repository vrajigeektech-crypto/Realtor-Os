import 'package:flutter/material.dart';

/// BrandAssetCard
/// Reusable stacked-card widget for Settings "Input Sections".
///
/// Use for: Logo Upload (and future brand assets like headshot, banner, etc.)
///
/// - Mobile responsive (expands to available width)
/// - Clickable (primary CTA + optional whole-card tap)
/// - Theme-safe (uses Theme.of(context) colors/typography; no hard-coded palette)
class BrandAssetCard extends StatelessWidget {
  const BrandAssetCard({
    super.key,
    this.title = 'Your Logo',
    this.description = 'Upload your logo so it appears alongside your content.',
    this.ctaLabel = 'Upload Logo',
    this.assetLabel = 'Logo',
    this.assetUrl,
    this.isUploading = false,
    this.uploadProgress, // 0.0 - 1.0
    this.onTapCard,
    this.onTapCta,
    this.onRemove,
  });

  /// Card title (default matches UX spec)
  final String title;

  /// Card description (default matches UX spec)
  final String description;

  /// Primary CTA label (default matches UX spec)
  final String ctaLabel;

  /// Label displayed in the preview box (e.g., "Logo")
  final String assetLabel;

  /// Optional existing asset URL to show a "uploaded" state.
  /// (Preview rendering is intentionally generic; wire this to your image loader later.)
  final String? assetUrl;

  /// Whether an upload is currently in progress.
  final bool isUploading;

  /// Optional upload progress (0.0 - 1.0). Only used when [isUploading] is true.
  final double? uploadProgress;

  /// Optional whole-card tap (e.g., open manage screen)
  final VoidCallback? onTapCard;

  /// Primary CTA tap (e.g., open file picker)
  final VoidCallback? onTapCta;

  /// Optional remove action (e.g., clear logo)
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTapCard,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 420;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    title: title,
                    description: description,
                  ),
                  const SizedBox(height: 12),
                  isNarrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _PreviewBox(
                              label: assetLabel,
                              isUploaded: assetUrl != null,
                              isUploading: isUploading,
                              uploadProgress: uploadProgress,
                            ),
                            const SizedBox(height: 12),
                            _ActionsRow(
                              ctaLabel: ctaLabel,
                              isUploading: isUploading,
                              onTapCta: onTapCta,
                              onRemove: onRemove,
                              isUploaded: assetUrl != null,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _PreviewBox(
                                label: assetLabel,
                                isUploaded: assetUrl != null,
                                isUploading: isUploading,
                                uploadProgress: uploadProgress,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _ActionsRow(
                              ctaLabel: ctaLabel,
                              isUploading: isUploading,
                              onTapCta: onTapCta,
                              onRemove: onRemove,
                              isUploaded: assetUrl != null,
                            ),
                          ],
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _PreviewBox extends StatelessWidget {
  const _PreviewBox({
    required this.label,
    required this.isUploaded,
    required this.isUploading,
    required this.uploadProgress,
  });

  final String label;
  final bool isUploaded;
  final bool isUploading;
  final double? uploadProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final borderColor = cs.outlineVariant.withOpacity(0.7);

    return Container(
      height: 92,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        color: cs.surfaceContainerHighest.withOpacity(0.35),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: cs.surface,
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Icon(
                isUploaded ? Icons.check_circle : Icons.image_outlined,
                color: isUploaded ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                if (isUploading) ...[
                  Text(
                    'Uploading…',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (uploadProgress != null)
                        ? uploadProgress!.clamp(0.0, 1.0)
                        : null,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ] else ...[
                  Text(
                    isUploaded ? 'Uploaded' : 'No file uploaded',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    required this.ctaLabel,
    required this.isUploading,
    required this.onTapCta,
    required this.onRemove,
    required this.isUploaded,
  });

  final String ctaLabel;
  final bool isUploading;
  final VoidCallback? onTapCta;
  final VoidCallback? onRemove;
  final bool isUploaded;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.icon(
          onPressed: isUploading ? null : onTapCta,
          icon: const Icon(Icons.upload_rounded),
          label: Text(ctaLabel),
        ),
        if (isUploaded && onRemove != null) ...[
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Remove',
            onPressed: isUploading ? null : onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ],
    );
  }
}
