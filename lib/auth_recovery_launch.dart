import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tracks password-recovery deep links so the app shows [NewPasswordScreen]
/// instead of the main shell while the user still has a recovery session.
class AuthRecoveryLaunch {
  AuthRecoveryLaunch._();

  static bool _active = false;

  static bool get isActive => _active;

  static void activate() => _active = true;

  static void clear() => _active = false;

  /// Web hosting URL + path (path URL strategy). Add this exact URL to Supabase
  /// Auth → URL Configuration → Redirect URLs.
  static String passwordResetRedirectUrl() {
    if (kIsWeb) {
      return '${Uri.base.origin}/reset-password';
    }
    return 'realtoros://reset-password';
  }

  static bool _uriLooksLikeRecoveryAuth(Uri uri) {
    if (uri.fragment.isNotEmpty) {
      final q = Uri.splitQueryString(uri.fragment);
      if (q['type'] == 'recovery' &&
          (q.containsKey('access_token') || q.containsKey('refresh_token'))) {
        return true;
      }
    }
    final qp = uri.queryParameters;
    if (qp['type'] == 'recovery' &&
        (qp.containsKey('access_token') || qp.containsKey('refresh_token'))) {
      return true;
    }
    return false;
  }

  /// After [Supabase.initialize], consume the current tab URL (Flutter web).
  static Future<void> consumeWebRecoveryUri(SupabaseClient client) async {
    if (!kIsWeb) return;
    final uri = Uri.base;
    if (!_uriLooksLikeRecoveryAuth(uri)) return;
    try {
      await client.auth.getSessionFromUrl(uri);
      _active = true;
    } catch (e) {
      debugPrint('[AuthRecovery] getSessionFromUrl (web) failed: $e');
    }
  }

  /// Cold start on mobile when the user opened `realtoros://reset-password#...`.
  static Future<void> consumeInitialAppLinkIfRelevant(SupabaseClient client) async {
    if (kIsWeb) return;
    try {
      final uri = await AppLinks().getInitialLink();
      if (uri == null) return;
      await consumeUriForRecovery(client, uri);
    } catch (e) {
      debugPrint('[AuthRecovery] getInitialLink failed: $e');
    }
  }

  /// Parses tokens from [uri] and opens a recovery session.
  static Future<void> consumeUriForRecovery(
    SupabaseClient client,
    Uri uri,
  ) async {
    if (!_uriLooksLikeRecoveryAuth(uri)) return;
    try {
      await client.auth.getSessionFromUrl(uri);
      _active = true;
    } catch (e) {
      debugPrint('[AuthRecovery] getSessionFromUrl failed: $e');
    }
  }
}
