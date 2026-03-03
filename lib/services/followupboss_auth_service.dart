// lib/services/followupboss_auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'supabase_service.dart';

class FollowUpBossAuthService {
  final _supabase = SupabaseService.instance.client;
  static const String _systemKey = 'faf48c01b12e37eed790202040ff847f';
  static const String _systemName = 'Realtor_OS';
  // Service role key for testing (matches main.dart)
  static const String _serviceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1hY2VucnVrb2RmZ2Zlb3dycXFmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTI4MTgzMSwiZXhwIjoyMDgwODU3ODMxfQ.O45T2KaEGQczxhGco1VNb_88cFd0Wo66_YW_u_kc_GU';

  Future<void> initiateAuth() async {
    try {
      debugPrint('🔐 [FUB] Starting authentication flow');

      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;

      debugPrint('🔐 [FUB] Session: ${session != null ? "EXISTS" : "NULL"}');
      debugPrint('🔐 [FUB] User: ${user?.email ?? "NULL"}');
      
      // Build headers - SDK automatically attaches Bearer token if user is logged in
      final headers = <String, String>{
        'X-System': _systemName,
        'X-System-Key': _systemKey,
      };
      
      Map<String, dynamic>? body;
      
      if (session != null) {
        debugPrint('🔐 [FUB] Using user session - SDK will attach Bearer token automatically');
        // SDK automatically attaches Authorization header when user is logged in
      } else {
        debugPrint('🔐 [FUB] No session - manually adding service_role token with test user ID');
        // When no session, manually add service_role token and pass user_id in body
        headers['Authorization'] = 'Bearer $_serviceRoleKey';
        body = {'user_id': 'c819a131-ca23-4296-a26a-aed7e430c735'};
      }

      debugPrint('🔐 [FUB] Calling edge function...');
      debugPrint('🔐 [FUB] Headers: ${headers.keys.toList()}');
      if (body != null) {
        debugPrint('🔐 [FUB] Body: $body');
      }

      final response = await _supabase.functions.invoke(
        'fub-auth',
        headers: headers,
        body: body,
      );

      debugPrint('🔐 [FUB] Response status: ${response.status}');
      debugPrint('🔐 [FUB] Response data type: ${response.data?.runtimeType ?? "null"}');
      debugPrint('🔐 [FUB] Response data: ${response.data}');

      if (response.status != 200) {
        final errorMsg = response.data?.toString() ?? 'Unknown error';
        throw Exception('Edge function failed: $errorMsg');
      }

      if (response.data == null) {
        debugPrint('❌ [FUB] Response data is null');
        throw Exception('No response data from server');
      }

      final data = response.data as Map<String, dynamic>?;
      final authUrl = data?['url'] as String?;

      if (authUrl == null || authUrl.isEmpty) {
        debugPrint('❌ [FUB] No URL in response: $data');
        throw Exception('No OAuth URL returned from server');
      }

      debugPrint('🔐 [FUB] OAuth URL received: ${authUrl.substring(0, 50)}...');
      debugPrint('🔐 [FUB] Opening URL in browser...');

      final uri = Uri.parse(authUrl);
      final canLaunch = await canLaunchUrl(uri);

      debugPrint('🔐 [FUB] Can launch URL: $canLaunch');

      if (canLaunch) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('🔐 [FUB] Launch result: $launched');

        if (launched) {
          debugPrint('✅ [FUB] Browser opened successfully');
        } else {
          debugPrint('❌ [FUB] Failed to open browser');
          throw Exception('Could not open browser');
        }
      } else {
        debugPrint('❌ [FUB] Cannot launch URL: $authUrl');
        throw Exception('Could not launch OAuth URL');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [FUB] Error: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> handleCallback(
    Map<String, dynamic> params,
  ) async {
    try {
      debugPrint('🔐 [FUB] Handling OAuth callback');

      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase.functions.invoke(
        'fub-callback',
        body: params,
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'X-System': _systemName,
          'X-System-Key': _systemKey,
        },
      );

      debugPrint('🔐 [FUB] Callback response: ${response.data}');

      if (response.status != 200) {
        throw Exception('OAuth callback failed: ${response.data}');
      }

      return response.data as Map<String, dynamic>? ?? {};
    } catch (e, stackTrace) {
      debugPrint('❌ [FUB] Callback error: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchApiData() async {
    try {
      debugPrint('📡 [FUB API] Fetching API data');

      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase.functions.invoke(
        'fub-api-data',
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'X-System': _systemName,
          'X-System-Key': _systemKey,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to fetch API data: ${response.data}');
      }

      debugPrint('✅ [FUB API] API data fetched successfully');
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e, stackTrace) {
      debugPrint('❌ [FUB API] Failed to fetch API data: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }
}
