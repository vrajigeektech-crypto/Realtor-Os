import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'screens/welcome_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/brand_setup_screen.dart';
import 'screens/voice_setup_screen.dart';
import 'screens/complete_screen.dart';

/// Main router for the new onboarding flow
class NewFlowRouter {
  static Map<String, Widget Function(BuildContext)> get routes => {
    '/new_flow': (context) => const NewFlowWelcomeScreen(),
    '/new_flow/welcome': (context) => const NewFlowWelcomeScreen(),
    '/new_flow/setup_profile': (context) => const NewFlowProfileSetupScreen(),
    '/new_flow/brand_setup': (context) => const NewFlowBrandSetupScreen(),
    '/new_flow/voice_setup': (context) => const NewFlowVoiceSetupScreen(),
    '/new_flow/complete': (context) => const NewFlowCompleteScreen(),
  };

  /// Generate onboarding routes for GetMaterialApp
  static Map<String, Widget> getOnboardingRoutes() {
    return {
      '/new_flow': const NewFlowWelcomeScreen(),
      '/new_flow/welcome': const NewFlowWelcomeScreen(),
      '/new_flow/setup_profile': const NewFlowProfileSetupScreen(),
      '/new_flow/brand_setup': const NewFlowBrandSetupScreen(),
      '/new_flow/voice_setup': const NewFlowVoiceSetupScreen(),
      '/new_flow/complete': const NewFlowCompleteScreen(),
    };
  }

  /// Check if user should see new onboarding flow
  static bool shouldUseNewFlow(String userId) {
    // TODO: Implement logic to determine if user should see new flow
    // This could be based on user creation date, feature flags, etc.
    return true;
  }

  /// Get entry point for new flow
  static String getEntryPoint() {
    return '/new_flow/welcome';
  }
}

/// Navigation helper for the new flow
class NewFlowNavigator {
  static void navigateToNext(BuildContext context, String currentRoute) {
    final routes = [
      '/new_flow/welcome',
      '/new_flow/setup_profile',
      '/new_flow/brand_setup',
      '/new_flow/voice_setup',
      '/new_flow/complete',
    ];

    final currentIndex = routes.indexOf(currentRoute);
    if (currentIndex != -1 && currentIndex < routes.length - 1) {
      Navigator.of(context).pushNamed(routes[currentIndex + 1]);
    }
  }

  static void navigateToPrevious(BuildContext context, String currentRoute) {
    final routes = [
      '/new_flow/welcome',
      '/new_flow/setup_profile',
      '/new_flow/brand_setup',
      '/new_flow/voice_setup',
      '/new_flow/complete',
    ];

    final currentIndex = routes.indexOf(currentRoute);
    if (currentIndex > 0) {
      Navigator.of(context).pushNamed(routes[currentIndex - 1]);
    }
  }

  static void skipToEnd(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/new_flow/complete',
      (route) => false,
    );
  }

  static void exitToDashboard(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/dashboard',
      (route) => false,
    );
  }
}
