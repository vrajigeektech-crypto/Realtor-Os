// lib/services/followupboss_auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'supabase_service.dart';
import '../utils/web_redirect.dart';

class FollowUpBossAuthService {
  final _supabase = SupabaseService.instance.client;
  static const String _systemKey = 'faf48c01b12e37eed790202040ff847f';
  static const String _systemName = 'Realtor_OS';

  /// The redirect URI used for Flutter Web OAuth.
  ///
  /// MUST be registered in Follow Up Boss app settings AND match exactly in
  /// both the /authorize request (fub-auth) and the /token exchange (exchange-token).
  ///
  /// No '#' fragment — OAuth 2.0 (RFC 6749 §3.1.2) forbids fragment components
  /// in redirect_uri values. Flutter Web uses path-based URL strategy instead.
  static const String kWebRedirectUri =
      'https://realtor--os.web.app/oauth/callback';

  Future<void> connectWithApiKey({required String apiKey}) async {
    try {
      debugPrint('🔗 [FUB] Starting API key connection...');

      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated. Please sign in first.');
      }

      final accessToken = session.accessToken;
      if (accessToken.isEmpty) {
        throw Exception('Invalid session: access token is missing.');
      }

      final response = await _supabase.functions.invoke(
        'fub_connect_private',
        body: {'api_key': apiKey},
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.status == 401) {
        throw Exception('Session expired. Please log in again.');
      }

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage =
            errorData?['error'] as String? ??
            errorData?['message'] as String? ??
            'Connection failed';
        throw Exception(errorMessage);
      }

      debugPrint('✅ [FUB] API key connection successful');
    } catch (e, stackTrace) {
      debugPrint('❌ [FUB] API key connection failed: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }

  /// Refreshes the OAuth access token using the stored refresh token.
  /// Returns the new access token on success, or throws on failure.
  /// Called automatically by [FollowUpBossContactService] when the token is
  /// expired or a 401 is received.
  Future<String> refreshToken() async {
    debugPrint('🔄 [FUB] Refreshing OAuth access token...');

    final session = _supabase.auth.currentSession;
    if (session == null) {
      throw Exception('User not authenticated. Please sign in first.');
    }

    final response = await _supabase.functions.invoke(
      'fub-refresh',
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );

    if (response.status != 200) {
      final errorData = response.data as Map<String, dynamic>?;
      final errorMsg =
          errorData?['details'] as String? ??
          errorData?['error'] as String? ??
          'Token refresh failed';
      throw Exception(errorMsg);
    }

    final data = response.data as Map<String, dynamic>;
    final newToken = data['access_token'] as String?;
    if (newToken == null || newToken.isEmpty) {
      throw Exception('No access token in refresh response');
    }

    debugPrint('✅ [FUB] Token refreshed successfully');
    return newToken;
  }

  /// Initiates the OAuth flow. Opens the FUB authorization page in an external
  /// browser. The server-side `fub-callback` edge function handles the redirect
  /// and saves tokens to `user_crm_connections`. On success the browser fires
  /// the `realtoros://fub-success` deep link so the app can refresh its state.
  Future<void> initiateAuth() async {
    try {
      debugPrint('🔐 [FUB] Starting OAuth flow');

      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated. Please sign in first.');
      }

      debugPrint('🔐 [FUB] Calling fub-auth edge function...');

      final response = await _supabase.functions.invoke(
        'fub-auth',
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'X-System': _systemName,
          'X-System-Key': _systemKey,
        },
      );

      debugPrint('🔐 [FUB] Response status: ${response.status}');

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMsg =
            errorData?['details'] as String? ??
            errorData?['error'] as String? ??
            response.data?.toString() ??
            'Unknown error';
        throw Exception('Could not start OAuth: $errorMsg');
      }

      final data = response.data as Map<String, dynamic>?;
      final authUrl = data?['url'] as String?;

      if (authUrl == null || authUrl.isEmpty) {
        throw Exception('No OAuth URL returned from server');
      }

      debugPrint('🔐 [FUB] Opening OAuth URL in browser...');

      final uri = Uri.parse(authUrl);
      if (!await canLaunchUrl(uri)) {
        throw Exception('Could not launch OAuth URL');
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('Could not open browser');
      }

      debugPrint('✅ [FUB] Browser opened for OAuth');
    } catch (e, stackTrace) {
      debugPrint('❌ [FUB] OAuth initiation failed: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }

  /// Web-specific OAuth flow: redirects the *current browser tab* to the FUB
  /// authorization page. FUB will redirect back to:
  ///   https://YOUR_DOMAIN/#/oauth/callback?code=AUTH_CODE&state=USER_ID
  ///
  /// The [OAuthCallbackScreen] handles that return URL, exchanges the code for
  /// tokens via the `exchange-token` Supabase edge function, and saves the
  /// connection. This method should only be called when [kIsWeb] is `true`;
  /// use [initiateAuth] for mobile/desktop.
  Future<void> initiateAuthForWeb() async {
    try {
      debugPrint('🔐 [FUB] Starting Web OAuth flow (full-page redirect)');

      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated. Please sign in first.');
      }

      // Call the fub-auth edge function to get the signed OAuth URL.
      // Pass redirect_uri explicitly so fub-auth uses the Flutter Web callback
      // route instead of the default server-side fub-callback function.
      final response = await _supabase.functions.invoke(
        'fub-auth',
        body: {'redirect_uri': kWebRedirectUri},
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'X-System': _systemName,
          'X-System-Key': _systemKey,
        },
      );

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMsg =
            errorData?['details'] as String? ??
            errorData?['error'] as String? ??
            'Unknown error';
        throw Exception('Could not start OAuth: $errorMsg');
      }

      final data = response.data as Map<String, dynamic>?;
      final authUrl = data?['url'] as String?;

      if (authUrl == null || authUrl.isEmpty) {
        throw Exception('No OAuth URL returned from server');
      }

      debugPrint('🔐 [FUB] Redirecting browser to OAuth URL…');

      // Full-page redirect: the browser navigates to FUB, completes OAuth,
      // then FUB redirects back to /#/oauth/callback with `code` + `state`.
      // Uses dart:html window.location.href on web; no-op stub on other platforms.
      redirectToUrl(authUrl);

      debugPrint('✅ [FUB] Browser redirect initiated');
    } catch (e, stackTrace) {
      debugPrint('❌ [FUB] Web OAuth initiation failed: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }
}
