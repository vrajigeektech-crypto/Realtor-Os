import '../models/social_integration_model.dart';

class SocialMediaIntegrationsRepository {
  /// READ — integrations list
  /// Supabase RPC: rpc_get_social_integrations
  Future<List<SocialIntegrationModel>> fetchIntegrations({
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const [
      SocialIntegrationModel(
        integrationKey: 'facebook',
        displayName: 'Facebook',
        group: 'social',
        connected: true,
        lastSyncedAt: null,
      ),
      SocialIntegrationModel(
        integrationKey: 'instagram',
        displayName: 'Instagram',
        group: 'social',
        connected: false,
        lastSyncedAt: null,
      ),
      SocialIntegrationModel(
        integrationKey: 'linkedin',
        displayName: 'LinkedIn',
        group: 'social',
        connected: true,
        lastSyncedAt: null,
      ),
      SocialIntegrationModel(
        integrationKey: 'tiktok',
        displayName: 'TikTok',
        group: 'social',
        connected: false,
        lastSyncedAt: null,
      ),
    ];
  }

  /// WRITE — connect integration
  /// Supabase RPC: rpc_connect_integration
  Future<void> connectIntegration({
    required String userId,
    required String integrationKey,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// WRITE — disconnect integration
  /// Supabase RPC: rpc_disconnect_integration
  Future<void> disconnectIntegration({
    required String userId,
    required String integrationKey,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// WRITE — refresh integration
  /// Supabase RPC: rpc_refresh_integration
  Future<void> refreshIntegration({
    required String userId,
    required String integrationKey,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
