import 'package:flutter/material.dart';
import '../../data/models/integration_models.dart';
import '../badges/status_badge.dart';
import '../buttons/integration_primary_button.dart';

class IntegrationTileCard extends StatelessWidget {
  final IntegrationModel integration;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final bool isLoading;

  const IntegrationTileCard({
    super.key,
    required this.integration,
    required this.onConnect,
    required this.onDisconnect,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnected = integration.connected;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (integration.imagePath != null)
                Image.asset(
                  integration.imagePath!,
                  width: 28,
                  height: 28,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      integration.icon,
                      size: 28,
                    );
                  },
                )
              else
                Icon(
                  integration.icon,
                  size: 28,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  integration.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              StatusBadge(
                connected: isConnected,
              ),
            ],
          ),
          if (integration.subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              integration.subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
          const Spacer(),
          IntegrationPrimaryButton(
            connected: isConnected,
            onConnect: onConnect,
            onDisconnect: onDisconnect,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
