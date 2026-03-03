// lib/services/ghl_connection_service.dart
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class GhlConnectionService {
  final _supabase = SupabaseService.instance.client;

  /// Connect to GoHighLevel using API key and Location ID
  /// Calls the ghl_connect_private Edge Function
  Future<void> connect({
    required String apiKey,
    required String locationId,
  }) async {
    try {
      debugPrint('🔗 [GHL] Starting connection...');
      debugPrint('🔗 [GHL] Location ID: $locationId');

      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated. Please sign in first.');
      }

      final accessToken = session.accessToken;
      if (accessToken.isEmpty) {
        throw Exception('Invalid session: access token is missing.');
      }

      debugPrint('🔗 [GHL] User authenticated: ${_supabase.auth.currentUser?.email}');
      debugPrint('🔗 [GHL] Calling ghl_connect_private edge function...');

      final response = await _supabase.functions.invoke(
        'ghl_connect_private',
        body: {
          'api_key': apiKey,
          'location_id': locationId,
        },
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('🔗 [GHL] Response status: ${response.status}');
      debugPrint('🔗 [GHL] Response data: ${response.data}');

      if (response.status == 401) {
        throw Exception('Session expired. Please log in again.');
      }
      
      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error'] as String? ??
            errorData?['message'] as String? ??
            'Connection failed';
        throw Exception(errorMessage);
      }

      debugPrint('✅ [GHL] Connection successful');
    } catch (e, stackTrace) {
      debugPrint('❌ [GHL] Connection failed: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }

  Future<void> syncContacts() async {
    try {
      debugPrint('🔄 [GHL] Starting contact sync...');

      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated. Please sign in first.');
      }

      final accessToken = session.accessToken;
      if (accessToken.isEmpty) {
        throw Exception('Invalid session: access token is missing.');
      }

      debugPrint('🔄 [GHL] Calling ghl_sync_leads edge function...');

      final response = await _supabase.functions.invoke(
        'ghl_sync_leads',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('🔄 [GHL] Response status: ${response.status}');
      debugPrint('🔄 [GHL] Response data: ${response.data}');

      if (response.status == 401) {
        throw Exception('Session expired. Please log in again.');
      }

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error'] as String? ??
            errorData?['message'] as String? ??
            'Sync failed';
        throw Exception(errorMessage);
      }

      debugPrint('✅ [GHL] Sync successful');
    } catch (e, stackTrace) {
      debugPrint('❌ [GHL] Sync failed: $e');
      debugPrint('   Stack: $stackTrace');
      debugPrint('   Error type: ${e.runtimeType}');
      
      // Provide more helpful error messages
      final errorString = e.toString();
      if (errorString.contains('Failed to fetch') || errorString.contains('ClientException')) {
        throw Exception('Edge Function not available. Please ensure ghl_sync_leads is deployed.');
      }
      
      rethrow;
    }
  }
}
