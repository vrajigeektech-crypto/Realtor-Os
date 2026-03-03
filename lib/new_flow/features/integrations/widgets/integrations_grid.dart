import 'package:flutter/material.dart';
import 'integration_card.dart';

class IntegrationsGrid extends StatelessWidget {
  const IntegrationsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: const [
        IntegrationCard(
          name: 'Salesforce',
          status: IntegrationStatus.connected,
        ),
        IntegrationCard(
          name: 'HubSpot',
          status: IntegrationStatus.disconnected,
        ),
        IntegrationCard(
          name: 'Follow Up Boss',
          status: IntegrationStatus.connected,
        ),
        IntegrationCard(
          name: 'Facebook',
          status: IntegrationStatus.disconnected,
        ),
        IntegrationCard(
          name: 'Instagram',
          status: IntegrationStatus.connected,
        ),
        IntegrationCard(
          name: 'LinkedIn',
          status: IntegrationStatus.disconnected,
        ),
        IntegrationCard(
          name: 'Stripe',
          status: IntegrationStatus.connected,
        ),
        IntegrationCard(
          name: 'PayPal',
          status: IntegrationStatus.disconnected,
        ),
        IntegrationCard(
          name: 'Calendly',
          status: IntegrationStatus.connected,
        ),
        IntegrationCard(
          name: 'Trello',
          status: IntegrationStatus.disconnected,
        ),
        IntegrationCard(
          name: 'Zapier',
          status: IntegrationStatus.disconnected,
        ),
        IntegrationCard(
          name: 'Google Drive',
          status: IntegrationStatus.connected,
        ),
      ],
    );
  }
}
