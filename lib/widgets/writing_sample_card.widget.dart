import 'package:flutter/material.dart';

class WritingSampleCard extends StatelessWidget {
  const WritingSampleCard({
    super.key,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.onCtaPressed,
  });

  final String title;
  final String description;
  final String ctaLabel;
  final VoidCallback onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onCtaPressed,
                child: Text(ctaLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
