import 'package:flutter/material.dart';
import '../controllers/google_integrations_controller.dart';
import '../widgets/google_integration_card.dart';

class GoogleIntegrationsGrid extends StatelessWidget {
  final GoogleIntegrationsController controller;

  const GoogleIntegrationsGrid({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white70),
      );
    }

    if (controller.state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading integrations',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.state.error!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.load(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCE9799),
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      children: controller.state.items.map((integration) {
        return GoogleIntegrationCard(
          title: integration.displayName,
          subtitle: integration.description,
          iconAsset: _getIconAsset(integration.integrationKey),
          connected: integration.connected,
          loading: controller.state.busyKeys.contains(integration.integrationKey),
          onConnect: () => controller.connect(integration.integrationKey),
          onDisconnect: () => controller.disconnect(integration.integrationKey),
        );
      }).toList(),
    );
  }

  String _getIconAsset(String integrationKey) {
    switch (integrationKey) {
      case 'calendar':
        return 'assets/icons/google_calendar.png';
      case 'my_business':
        return 'assets/icons/google_my_business.png';
      case 'contacts':
        return 'assets/icons/google_contacts.png';
      case 'drive':
        return 'assets/icons/google_drive.png';
      default:
        return 'assets/icons/google_default.png';
    }
  }
}
