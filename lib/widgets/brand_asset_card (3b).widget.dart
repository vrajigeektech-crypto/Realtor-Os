// brand_asset_card.dart
//
// Reusable card widget for uploading an agent headshot.
// - Themeable (uses Theme.of(context).colorScheme / textTheme)
// - Mobile reactive (LayoutBuilder + wraps)
// - Clickable CTA (Upload Headshot)
// - Optional preview image + status text

import 'package:flutter/material.dart';

class BrandAssetCard extends StatelessWidget {
  const BrandAssetCard({
    super.key,
    this.title = 'Your Headshot',
    this.description =
        'Upload a professional headshot so clients recognize you instantly.',
    this.ctaLabel = 'Upload Headshot',
    this.assetTypeLabel = 'Headshot Upload',
    this.imageUrl,
    this.fileName,
    this.lastUpdatedLabel,
    this.isUploading = false,
    this.isDisabled = false,
    this.onUploadPressed,
    this.onCardTap,
    this.onRemovePressed,
    this.showRemove = false,
  });

  /// Section label shown above the card (e.g. "3B. Headshot Upload")
  final String assetTypeLabel;

  /// Card title (e.g. "Your Headshot")
  final String title;

  /// Card description copy
  final String description;

  /// Primary CTA label (e.g. "Upload Headshot")
  final String ctaLabel;

  /// Optional preview image URL (network). If null, shows placeholder.
  final String? imageUrl;

  /// Optional uploaded file name.
  final String? fileName;

  /// Optional timestamp/copy like "Updated 2 days ago".
  final String? lastUpdatedLabel;

  /// If true, show progress indicator and disable CTA.
  final bool isUploading;

  /// If true, disable interactions.
  final bool isDisabled;

  /// Called when CTA is pressed.
  final VoidCallback? onUploadPressed;

  /// Called when card body is tapped.
  final VoidCallback? onCardTap;

  /// Optional remove action
  final VoidCallback? onRemovePressed;

  /// Show remove button in footer
  final bool showRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final disabled = isDisabled || isUploading;
    final borderColor = cs.outlineVariant.withOpacity(0.55);
    final bg = cs.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: assetTypeLabel),
        const SizedBox(height: 10),
        InkWell(
          onTap: disabled ? null : onCardTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 520;

                final preview = _HeadshotPreview(
                  imageUrl: imageUrl,
                  isUploading: isUploading,
                );

                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MetaRow(
                      fileName: fileName,
                      lastUpdatedLabel: lastUpdatedLabel,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: disabled ? null : onUploadPressed,
                          icon: isUploading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.upload_rounded),
                          label: Text(ctaLabel),
                        ),
                        if (showRemove)
                          TextButton.icon(
                            onPressed: disabled ? null : onRemovePressed,
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Remove'),
                          ),
                      ],
                    ),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      preview,
                      const SizedBox(height: 14),
                      content,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 140, child: preview),
                    const SizedBox(width: 16),
                    Expanded(child: content),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.7),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
          ),
          child: Text(
            label,
            style: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeadshotPreview extends StatelessWidget {
  const _HeadshotPreview({
    required this.imageUrl,
    required this.isUploading,
  });

  final String? imageUrl;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
          color: cs.surfaceContainerHighest.withOpacity(0.35),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null && imageUrl!.trim().isNotEmpty)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(context),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _loadingOverlay(context);
                },
              )
            else
              _placeholder(context),
            if (isUploading) _loadingOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_rounded, size: 40, color: cs.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'No headshot',
            style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _loadingOverlay(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface.withOpacity(0.55),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.fileName,
    required this.lastUpdatedLabel,
  });

  final String? fileName;
  final String? lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final chips = <Widget>[];

    if (fileName != null && fileName!.trim().isNotEmpty) {
      chips.add(_Chip(
        icon: Icons.insert_drive_file_outlined,
        label: fileName!,
      ));
    }

    if (lastUpdatedLabel != null && lastUpdatedLabel!.trim().isNotEmpty) {
      chips.add(_Chip(
        icon: Icons.schedule_outlined,
        label: lastUpdatedLabel!,
      ));
    }

    if (chips.isEmpty) {
      return Text(
        'Tip: Use a well-lit, front-facing photo.',
        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
        color: cs.surfaceContainerHighest.withOpacity(0.25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: tt.labelMedium?.copyWith(color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}
