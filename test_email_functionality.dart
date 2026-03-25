import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/services/supabase_service.dart';

/// Test script to verify email functionality
/// Run this with: dart run test_email_functionality.dart

Future<void> main() async {
  print('🔧 Testing Email Functionality...\n');
  
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://macenrukodfgfeowrqqf.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1hY2VucnVrb2RmZ2Zlb3dycXFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyODE4MzEsImV4cCI6MjA4MDg1NzgzMX0.S1APXcPgh0UNCbqm62WE_7s01A0qiINS5r1Q2xl5fFE',
    );

    final supabase = SupabaseService.instance.client;
    
    // Test 1: Check current auth configuration
    print('1️⃣ Checking Auth Configuration...');
    try {
      final session = supabase.auth.currentSession;
      print('   Current session: ${session != null ? "Active" : "None"}');
      
      final user = supabase.auth.currentUser;
      if (user != null) {
        print('   User email: ${user.email}');
        print('   Email confirmed: ${user.emailConfirmedAt != null}');
        print('   Created at: ${user.createdAt}');
      } else {
        print('   No current user');
      }
    } catch (e) {
      print('   ❌ Error checking config: $e');
    }
    
    // Test 2: Test password reset email
    print('\n2️⃣ Testing Password Reset Email...');
    try {
      const testEmail = 'test@example.com'; // Replace with actual test email
      await supabase.auth.resetPasswordForEmail(testEmail);
      print('   ✅ Password reset email sent to: $testEmail');
      print('   📧 Check your email inbox (and spam folder)');
    } catch (e) {
      print('   ❌ Failed to send password reset: $e');
      
      if (e.toString().contains('User not found')) {
        print('   💡 This is expected if the test email doesn\'t exist');
      }
    }
    
    // Test 3: Test signup verification (if needed)
    print('\n3️⃣ Testing Signup Verification Flow...');
    print('   💡 To test signup verification:');
    print('      1. Create a new account in the app');
    print('      2. Check email for verification link');
    print('      3. Click the link to verify');
    
    // Test 4: Check email templates
    print('\n4️⃣ Email Template Configuration:');
    print('   💡 Ensure email templates are configured in Supabase:');
    print('      - Go to Authentication → Email Templates');
    print('      - Check that templates are enabled');
    print('      - Verify sender email is configured');
    
    print('\n✅ Email functionality test completed!');
    print('\n📋 Troubleshooting Checklist:');
    print('   □ Check spam/junk folders');
    print('   □ Verify email address is correct');
    print('   □ Ensure Supabase email service is enabled');
    print('   □ Check rate limiting (wait 1 min between attempts)');
    print('   □ Verify redirect URLs are configured');
    
  } catch (e) {
    print('❌ Test failed: $e');
  }
}
