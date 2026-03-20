// lib/services/api_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin HTTP wrapper for calls to Supabase Edge Functions that need an
/// explicit `http` client (e.g. token exchange during OAuth callback).
class ApiService {
  static const String _functionsBaseUrl =
      'https://macenrukodfgfeowrqqf.supabase.co/functions/v1';

  /// Exchanges the Follow Up Boss OAuth [code] for access/refresh tokens by
  /// calling the `exchange-token` Supabase edge function.
  ///
  /// [code]        – the authorization code received in the `#/oauth/callback` URL.
  /// [redirectUri] – MUST exactly match the redirect_uri used in the original
  ///                 /authorize request. FUB validates this on the token endpoint.
  /// [state]       – the `state` value echoed back by FUB (user ID); forwarded
  ///                 to FUB's token endpoint as required by their spec.
  ///
  /// Throws an [Exception] with a human-readable message on any failure.
  static Future<void> exchangeToken({
    required String code,
    required String redirectUri,
    String? state,
  }) async {
    // Attach the current user's Supabase JWT so the edge function can identify
    // the caller without relying on the state param for authentication.
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception('User is not authenticated. Please sign in first.');
    }

    final uri = Uri.parse('$_functionsBaseUrl/exchange-token');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: jsonEncode({
        'code': code,
        'redirect_uri': redirectUri,
        if (state != null && state.isNotEmpty) 'state': state,
      }),
    );

    Map<String, dynamic> body = {};
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      // Non-JSON body – surface the raw text as the error message.
    }

    if (response.statusCode != 200) {
      final errorMsg =
          body['details'] as String? ??
          body['error'] as String? ??
          'Token exchange failed (HTTP ${response.statusCode})';
      throw Exception(errorMsg);
    }
  }
}
