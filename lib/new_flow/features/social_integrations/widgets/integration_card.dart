import 'package:flutter/material.dart';
import '../controllers/social_media_integrations_state.dart';
import 'integration_status_badge.dart';
import 'integration_connect_button.dart';

class IntegrationCard extends StatelessWidget {
  const IntegrationCard({
    super.key,
    required this.item,
    required this.busy,
    required this.onConnect,
    required this.onDisconnect,
  });

  final SocialIntegrationItem item;
  final bool busy;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PlatformIcon(keyName: item.integrationKey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IntegrationStatusBadge(connected: item.connected),
            ],
          ),
          const Spacer(),
          IntegrationConnectButton(
            connected: item.connected,
            busy: busy,
            onConnect: onConnect,
            onDisconnect: onDisconnect,
          ),
          if (item.lastSyncedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last synced: ${_format(item.lastSyncedAt!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _format(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _PlatformIcon extends StatelessWidget {
  const _PlatformIcon({required this.keyName});

  final String keyName;

  @override
  Widget build(BuildContext context) {
    String imagePath;
    switch (keyName) {
      case 'facebook':
        imagePath = 'assets/facebook_logo.png';
        break;
      case 'instagram':
        imagePath = 'assets/instagram_logo.png';
        break;
      case 'linkedin':
        imagePath = 'assets/linkedin_logo.png';
        break;
      case 'tiktok':
        imagePath = 'assets/ic_tiktok.svg';
        break;
      default:
        return Icon(Icons.extension_outlined, size: 28);
    }

    return Image.asset(
      imagePath,
      width: 28,
      height: 28,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.extension_outlined, size: 28);
      },
    );
  }
}
