import '../models/google_integration_model.dart';

class GoogleIntegrationsService {
  /// READ — fetch Google integrations
  /// Supabase RPC: rpc_get_google_integrations
  Future<List<GoogleIntegrationModel>> fetchGoogleIntegrations() async {
    // Replace with Supabase RPC call
    await Future.delayed(const Duration(milliseconds: 300));

    return const [
      GoogleIntegrationModel(
        integrationKey: 'calendar',
        displayName: 'Google Calendar',
        description: 'Sync events with your calendar',
        connected: true,
      ),
      GoogleIntegrationModel(
        integrationKey: 'my_business',
        displayName: 'Google My Business',
        description: 'Manage reviews and business info',
        connected: false,
      ),
      GoogleIntegrationModel(
        integrationKey: 'contacts',
        displayName: 'Google Contacts',
        description: 'Access and sync your contacts',
        connected: false,
      ),
      GoogleIntegrationModel(
        integrationKey: 'drive',
        displayName: 'Google Drive',
        description: 'Sync files and documents',
        connected: true,
      ),
    ];
  }

  /// WRITE — start Google OAuth
  /// Supabase RPC: rpc_get_google_oauth_url
  Future<void> startOAuth(String integrationKey) async {
    // Supabase call returns redirect URL
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// WRITE — disconnect Google integration
  /// Supabase RPC: rpc_disconnect_integration
  Future<void> disconnectIntegration(String integrationKey) async {
    // Supabase call here
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
