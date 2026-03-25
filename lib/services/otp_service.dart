import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Forgot-password uses Edge Functions `forgot-password-send-otp` and
/// `forgot-password-complete` (not Supabase Auth recovery email).
class OtpService {
  static const String _deployHint =
      'Deploy Edge Functions from the project root: '
      'supabase functions deploy forgot-password-send-otp forgot-password-complete --no-verify-jwt '
      '(apply migration 20260325140000_password_reset_challenges.sql first). '
      'Dashboard: Edge Functions → each function → disable “Enforce JWT verification” if the CLI flag was not applied.';

  /// Returns `true` if the server sent email via Resend; `false` if the code
  /// exists only in function logs (no RESEND_API_KEY).
  static Future<bool> sendPasswordRecoveryEmail(String email) async {
    try {
      final response = await SupabaseService.instance.client.functions.invoke(
        'forgot-password-send-otp',
        body: {'email': email.trim()},
      );
      if (response.status != 200) {
        final data = response.data;
        final msg = data is Map && data['error'] != null
            ? data['error'].toString()
            : 'Failed to send verification code';
        debugPrint('❌ [OtpService] send-otp ${response.status} $data');
        throw Exception(msg);
      }
      final data = response.data;
      if (data is Map && data['ok'] == false) {
        debugPrint('❌ [OtpService] send-otp failed (ok:false) $data');
        throw _mapToSendOtpFailureException(
          Map<String, dynamic>.from(data),
        );
      }
      if (data is Map && data['email_sent'] == false) {
        debugPrint(
          '⚠️ [OtpService] No RESEND_API_KEY — code is only in Edge Function logs',
        );
        return false;
      }
      return true;
    } on FunctionException catch (e) {
      debugPrint(
        '❌ [OtpService] FunctionException: ${e.status} ${e.details} '
        '(reason: ${e.reasonPhrase})',
      );
      if (e.status == 404) {
        throw Exception(
          'Password reset is not set up: the server returned “function not found”. $_deployHint',
        );
      }
      throw _functionErrorToException(e, fallback: 'Failed to send verification code');
    } on ClientException catch (e) {
      debugPrint('❌ [OtpService] ClientException: ${e.message}');
      if (kIsWeb &&
          (e.message.contains('Failed to fetch') ||
              e.message.contains('Failed to execute fetch'))) {
        throw Exception(
          'Could not reach the password reset service (browser blocked the request). '
          'Usually this means the Edge Function is not deployed yet — a missing function '
          'returns 404 on the CORS preflight, which shows up as “Failed to fetch”. $_deployHint',
        );
      }
      rethrow;
    }
  }

  /// Server validates the 6-digit code before showing the new-password screen.
  static Future<void> verifyPasswordRecoveryOtp(String email, String otp) async {
    try {
      final response = await SupabaseService.instance.client.functions.invoke(
        'forgot-password-complete',
        body: {
          'email': email.trim(),
          'otp': otp.trim(),
          'verify_only': true,
        },
      );
      if (response.status != 200) {
        final data = response.data;
        final msg = data is Map && data['error'] != null
            ? data['error'].toString()
            : 'Invalid or expired verification code';
        throw Exception(msg);
      }
    } on FunctionException catch (e) {
      if (e.status == 404) {
        throw Exception(
          'Password reset is not set up on the server. $_deployHint',
        );
      }
      throw _functionErrorToException(
        e,
        fallback: 'Invalid or expired verification code',
      );
    } on ClientException catch (e) {
      if (kIsWeb &&
          (e.message.contains('Failed to fetch') ||
              e.message.contains('Failed to execute fetch'))) {
        throw Exception(
          'Could not reach the server to verify the code. $_deployHint',
        );
      }
      rethrow;
    }
  }

  static Exception _mapToSendOtpFailureException(Map<String, dynamic> data) {
    final err = data['error']?.toString() ?? '';
    final extra = data['details']?.toString() ?? '';
    final combined = '$err $extra'.toLowerCase();
    if (combined.contains('only send testing emails') ||
        combined.contains('verify a domain at resend')) {
      return Exception(
        'Reset emails can only go to your Resend signup address until a domain is verified.\n\n'
        'To allow every user: add your domain at resend.com/domains (DNS), then in Supabase → '
        'Edge Functions → Secrets set MAIL_FROM to e.g. "MyApp <noreply@yourdomain.com>".',
      );
    }
    final hint = data['hint']?.toString();
    final parts = <String>[];
    if (err.isNotEmpty) parts.add(err);
    if (extra.isNotEmpty && !err.contains(extra)) parts.add(extra);
    if (hint != null && hint.isNotEmpty) parts.add(hint);
    if (parts.isEmpty) {
      return Exception('Could not send verification email');
    }
    return Exception(parts.join('\n\n'));
  }

  static Exception _functionErrorToException(
    FunctionException e, {
    required String fallback,
  }) {
    final details = e.details;
    if (details is Map) {
      final err = details['error'] ?? details['message'];
      final extra = details['details'];
      final hint = details['hint'];
      final parts = <String>[];
      if (err != null) parts.add(err.toString());
      if (extra != null && extra.toString().isNotEmpty) {
        final ex = extra.toString();
        final base = err?.toString() ?? '';
        if (!base.contains(ex)) parts.add(ex);
      }
      if (hint != null && hint.toString().isNotEmpty) {
        parts.add(hint.toString());
      }
      if (parts.isNotEmpty) return Exception(parts.join('\n\n'));
    }
    if (details is String && details.isNotEmpty) return Exception(details);
    return Exception(fallback);
  }
}
