import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://macenrukodfgfeowrqqf.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1hY2VucnVrb2RmZ2Zlb3dycXFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyODE4MzEsImV4cCI6MjA4MDg1NzgzMX0.S1APXcPgh0UNCbqm62WE_7s01A0qiINS5r1Q2xl5fFE';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: '190643825007-2jvmhqtpevtc47tph5fjfkbfkk3uk8lq.apps.googleusercontent.com',
    serverClientId: '190643825007-2jvmhqtpevtc47tph5fjfkbfkk3uk8lq.apps.googleusercontent.com',
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoogleSignIn get googleSignIn => _googleSignIn;

  static Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      return await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await client.auth.signOut();
  }
}
