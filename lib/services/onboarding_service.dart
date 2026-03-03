import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class OnboardingService {
  static const String _usersTable = 'users';
  
  static Future<bool> isOnboardingCompleted() async {
    try {
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) return false;

      final response = await SupabaseService.instance.client
          .from(_usersTable)
          .select('onboarding_completed')
          .eq('id', user.id)
          .single();
      
      return response['onboarding_completed'] as bool? ?? false;
    } catch (e) {
      debugPrint('⚠️ [OnboardingService] Error checking status: $e');
      return false;
    }
  }
  
  static Future<void> completeOnboarding() async {
    try {
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) return;

      await SupabaseService.instance.client
          .from(_usersTable)
          .update({'onboarding_completed': true})
          .eq('id', user.id);
      
      debugPrint('✅ [OnboardingService] Onboarding marked as completed in DB');
    } catch (e) {
      debugPrint('❌ [OnboardingService] Error completing onboarding: $e');
    }
  }

  static Future<void> updateOnboardingData(Map<String, dynamic> data) async {
    try {
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) return;

      await SupabaseService.instance.client
          .from(_usersTable)
          .update(data)
          .eq('id', user.id);
      
      debugPrint('✅ [OnboardingService] Onboarding data updated: $data');
    } catch (e) {
      debugPrint('❌ [OnboardingService] Error updating onboarding data: $e');
      // Don't rethrow - handle gracefully for missing table
      if (e.toString().contains('Could not find the table')) {
        debugPrint('⚠️ [OnboardingService] Users table not found - please run database migration');
      } else {
        rethrow;
      }
    }
  }
  
  static Future<int> getOnboardingStep() async {
    try {
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) return 0;

      final response = await SupabaseService.instance.client
          .from(_usersTable)
          .select('onboarding_step')
          .eq('id', user.id)
          .single();
      
      return response['onboarding_step'] as int? ?? 0;
    } catch (e) {
      debugPrint('⚠️ [OnboardingService] Error getting step: $e');
      return 0;
    }
  }
}
