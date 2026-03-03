import 'package:flutter/material.dart';
import 'integration_status_badge.dart';
import 'integration_connect_button.dart';

class GoogleIntegrationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconAsset;
  final bool connected;
  final bool loading;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const GoogleIntegrationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.connected,
    required this.loading,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        color: Colors.black.withOpacity(0.15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Icon placeholder - replace with actual image when available
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.extension,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (connected && !loading)
            const IntegrationStatusBadge(connected: true)
          else
            IntegrationConnectButton(
              connected: connected,
              loading: loading,
              onConnect: onConnect,
              onDisconnect: onDisconnect,
            ),
        ],
      ),
    );
  }
}
