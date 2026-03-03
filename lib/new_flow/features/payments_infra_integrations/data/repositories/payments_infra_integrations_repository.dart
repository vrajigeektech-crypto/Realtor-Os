import 'package:flutter/material.dart';
import '../models/integration_models.dart';

class PaymentsInfraIntegrationsRepository {
  Future<List<IntegrationModel>> fetchIntegrations({required String userId}) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      IntegrationModel(
        integrationKey: 'stripe',
        displayName: 'Stripe',
        providerGroup: 'payments_infra',
        connected: true,
        subtitle: 'Next Payout: \$1,267.25 scheduled for Apr 25',
      ),
      IntegrationModel(
        integrationKey: 'plaid',
        displayName: 'Plaid',
        providerGroup: 'payments_infra',
        connected: false,
      ),
      IntegrationModel(
        integrationKey: 'zapier',
        displayName: 'Zapier',
        providerGroup: 'payments_infra',
        connected: false,
      ),
      IntegrationModel(
        integrationKey: 'webhooks',
        displayName: 'Webhooks/API',
        providerGroup: 'payments_infra',
        connected: true,
        subtitle: 'Configured',
      ),
    ];
  }

  Future<void> connectIntegration({
    required String userId,
    required String integrationKey,
  }) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> disconnectIntegration({
    required String userId,
    required String integrationKey,
  }) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 2));
  }
}
