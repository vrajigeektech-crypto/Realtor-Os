import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

/// Utility to create the Super Admin user in Supabase
/// Run this once to set up the admin@gmail.com user
class SuperAdminSetup {
  static const String superAdminEmail = 'admin@gmail.com';
  static const String superAdminPassword = '111111';

  /// Create the Super Admin user using Supabase Admin API
  static Future<bool> createSuperAdminUser() async {
    try {
      // Initialize Supabase with service role key (if available)
      // Note: This requires service role key which has admin privileges
      
      // For now, we'll use the signup method which creates the user
      final response = await Supabase.instance.client.auth.signUp(
        email: superAdminEmail,
        password: superAdminPassword,
        data: {
          'role': 'Super Admin',
          'is_super_admin': true,
          'display_name': 'Super Admin',
        },
      );

      if (response.user != null) {
        print('✅ Super Admin user created successfully');
        print('   Email: $superAdminEmail');
        print('   User ID: ${response.user!.id}');
        
        // Confirm the email manually (since we're creating programmatically)
        await Supabase.instance.client.auth.admin.updateUserById(
          response.user!.id,
          attributes: AdminUserAttributes(
            emailConfirm: true,
            userMetadata: {
              'role': 'Super Admin',
              'is_super_admin': true,
              'display_name': 'Super Admin',
            },
          ),
        );
        
        return true;
      } else {
        print('❌ Failed to create Super Admin user');
        return false;
      }
    } catch (e) {
      print('❌ Error creating Super Admin user: $e');
      
      // Check if user already exists
      if (e.toString().contains('already registered')) {
        print('ℹ️  Super Admin user already exists');
        return true;
      }
      return false;
    }
  }

  /// Verify the Super Admin user exists and has correct metadata
  static Future<bool> verifySuperAdminUser() async {
    try {
      final response = await Supabase.instance.client.auth.admin.listUsers();
      final superAdminUser = response.users.firstWhere(
        (user) => user.email == superAdminEmail,
        orElse: () => throw Exception('User not found'),
      );

      print('✅ Super Admin user found:');
      print('   Email: ${superAdminUser.email}');
      print('   ID: ${superAdminUser.id}');
      print('   Metadata: ${superAdminUser.userMetadata}');
      print('   Email Confirmed: ${superAdminUser.emailConfirmedAt != null}');
      
      return true;
    } catch (e) {
      print('❌ Super Admin user verification failed: $e');
      return false;
    }
  }
}

/// Test app to run the Super Admin setup
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase (make sure you have the correct URL and anon key)
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL', // Replace with your actual Supabase URL
    anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your actual anon key
  );

  print('🔧 Setting up Super Admin user...');
  
  // Create the Super Admin user
  final created = await SuperAdminSetup.createSuperAdminUser();
  
  if (created) {
    print('✅ Setup completed successfully');
    
    // Verify the user
    await SuperAdminSetup.verifySuperAdminUser();
  } else {
    print('❌ Setup failed');
  }
}
