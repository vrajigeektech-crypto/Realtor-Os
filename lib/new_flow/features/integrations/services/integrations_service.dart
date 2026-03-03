import 'package:flutter/material.dart';
import '../models/integration_group_model.dart';
import '../models/integration_model.dart';

class IntegrationsService {
  /// RPC: rpc_get_integrations_all_set_header
  Future<_AllSetHeaderDTO> fetchAllSetHeader(String userId) async {
    // Replace with Supabase RPC call
    await Future.delayed(const Duration(milliseconds: 300));

    return const _AllSetHeaderDTO(
      title: "You're all set",
      subtitle: 'All core systems are connected and operational.',
      connectedCount: 11,
      totalCount: 12,
      completionPercent: 92,
    );
  }

  /// RPC: rpc_get_integrations_all_set_grid
  Future<List<IntegrationGroupModel>> fetchAllSetGrid(String userId) async {
    // Replace with Supabase RPC call
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      IntegrationGroupModel(
        groupKey: 'payments',
        title: 'Payments',
        subtitle: 'Billing & payouts',
        items: [
          IntegrationModel(
            integrationKey: 'stripe',
            displayName: 'Stripe',
            status: IntegrationStatus.connected,
            icon: Icons.payments_outlined,
          ),
        ],
      ),
      IntegrationGroupModel(
        groupKey: 'crm',
        title: 'CRM',
        subtitle: 'Lead & client management',
        items: [
          IntegrationModel(
            integrationKey: 'hubspot',
            displayName: 'HubSpot',
            status: IntegrationStatus.connected,
            icon: Icons.business_outlined,
          ),
          IntegrationModel(
            integrationKey: 'salesforce',
            displayName: 'Salesforce',
            status: IntegrationStatus.disconnected,
            icon: Icons.business_outlined,
          ),
        ],
      ),
      IntegrationGroupModel(
        groupKey: 'social',
        title: 'Social Media',
        subtitle: 'Advertising and social signals',
        items: [
          IntegrationModel(
            integrationKey: 'facebook',
            displayName: 'Facebook',
            status: IntegrationStatus.connected,
            icon: Icons.facebook_outlined,
          ),
          IntegrationModel(
            integrationKey: 'instagram',
            displayName: 'Instagram',
            status: IntegrationStatus.disconnected,
            icon: Icons.camera_alt_outlined,
          ),
        ],
      ),
    ];
  }

  /// RPC: rpc_integration_action
  Future<_IntegrationActionResult> integrationAction({
    required String userId,
    required String integrationKey,
    required String action,
  }) async {
    // Replace with Supabase RPC call
    await Future.delayed(const Duration(milliseconds: 250));

    return const _IntegrationActionResult(
      success: true,
      status: 'connected',
      statusLabel: 'Connected',
      connected: true,
      configured: true,
      authUrl: null,
      manageRoute: null,
    );
  }
}

/// INTERNAL DTOs (RPC-mapped)

class _AllSetHeaderDTO {
  final String title;
  final String subtitle;
  final int connectedCount;
  final int totalCount;
  final int completionPercent;

  const _AllSetHeaderDTO({
    required this.title,
    required this.subtitle,
    required this.connectedCount,
    required this.totalCount,
    required this.completionPercent,
  });
}

class _IntegrationActionResult {
  final bool success;
  final String status;
  final String statusLabel;
  final bool connected;
  final bool configured;
  final String? authUrl;
  final String? manageRoute;

  const _IntegrationActionResult({
    required this.success,
    required this.status,
    required this.statusLabel,
    required this.connected,
    required this.configured,
    required this.authUrl,
    required this.manageRoute,
  });
}
