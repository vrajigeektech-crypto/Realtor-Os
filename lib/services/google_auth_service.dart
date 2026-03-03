import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = SupabaseConfig.googleSignIn;

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  Future<GoogleSignInAccount?> getCurrentUser() async {
    return await _googleSignIn.currentUser;
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      debugPrint('🔐 [GoogleAuth] Starting Google sign-in...');
      
      // First, ensure we're signed out to start fresh
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('⚠️ [GoogleAuth] Sign-in cancelled by user');
        return AuthResult.cancelled();
      }

      debugPrint('✅ [GoogleAuth] Got Google user: ${googleUser.email}');
      
      // Get authentication tokens with retry logic
      GoogleSignInAuthentication? googleAuth;
      int retryCount = 0;
      const maxRetries = 3;
      
      do {
        try {
          googleAuth = await googleUser.authentication;
          if (googleAuth.idToken != null) {
            break; // Success, exit retry loop
          }
        } catch (e) {
          retryCount++;
          debugPrint('⚠️ [GoogleAuth] Token fetch attempt $retryCount failed: $e');
          if (retryCount >= maxRetries) rethrow;
          
          // Wait a bit before retrying
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        }
      } while (retryCount < maxRetries);
      
      if (googleAuth == null) {
        return AuthResult.error('Failed to get Google authentication after $maxRetries attempts');
      }
      
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      debugPrint('🔑 [GoogleAuth] Token status:');
      debugPrint('   - Access token: ${accessToken != null ? "Present (${accessToken.length} chars)" : "NULL"}');
      debugPrint('   - ID token: ${idToken != null ? "Present (${idToken.length} chars)" : "NULL"}');

      if (idToken == null) {
        debugPrint('❌ [GoogleAuth] ID token is null - this is the main issue');
        return AuthResult.error('Failed to get ID token from Google. Please check your Google Cloud Console configuration.');
      }

      debugPrint('🔑 [GoogleAuth] Got tokens, signing into Supabase...');
      
      final authResponse = await SupabaseConfig.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      debugPrint('🎉 [GoogleAuth] Successfully signed in: ${authResponse.user?.email}');
      return AuthResult.success(authResponse);
      
    } catch (e) {
      debugPrint('❌ [GoogleAuth] Sign-in failed: $e');
      
      // Provide more specific error messages
      String errorMessage = e.toString();
      if (errorMessage.contains('network')) {
        return AuthResult.error('Network error. Please check your internet connection and try again.');
      } else if (errorMessage.contains('12501') || errorMessage.contains('canceled')) {
        return AuthResult.cancelled();
      } else if (errorMessage.contains('10') || errorMessage.contains('developer')) {
        return AuthResult.error('Google Sign-In is not properly configured. Please check your client ID setup.');
      } else {
        return AuthResult.error('Google sign-in failed: $errorMessage');
      }
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('🔓 [GoogleAuth] Signing out...');
      await _googleSignIn.signOut();
      await SupabaseConfig.signOut();
      debugPrint('✅ [GoogleAuth] Successfully signed out');
    } catch (e) {
      debugPrint('❌ [GoogleAuth] Sign-out failed: $e');
      rethrow;
    }
  }
}

class AuthResult {
  final bool success;
  final bool cancelled;
  final String? error;
  final dynamic authResponse;

  AuthResult({
    required this.success,
    this.cancelled = false,
    this.error,
    this.authResponse,
  });

  factory AuthResult.success(dynamic authResponse) {
    return AuthResult(success: true, authResponse: authResponse);
  }

  factory AuthResult.error(String error) {
    return AuthResult(success: false, error: error);
  }

  factory AuthResult.cancelled() {
    return AuthResult(success: false, cancelled: true);
  }
}
