import 'dart:developer';

import 'package:demo/screens/agent_wallet_screen.dart';
import 'package:demo/screens/broker_wallet_screen.dart';
import 'package:demo/screens/dashboard_screen.dart';
import 'package:demo/screens/wallet_dashboard.dart';
import 'package:demo/screens/responsive_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'screens/login_screen.dart';
import 'core/app_colors.dart';
import 'theme/app_theme.dart';
import 'services/supabase_service.dart';
import 'services/onboarding_service.dart';
import 'services/balance_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/market_place_screen.dart';
import 'screens/reset_password_screen.dart';
import 'supabase_config.dart';
import 'web_file_input.dart';
import 'screens/controller/auth_controller.dart';
import 'screens/wallet/wallet_screen.dart';
import 'new_flow/screens/welcome_screen.dart';
import 'new_flow/screens/profile_setup_screen.dart';
import 'new_flow/screens/brand_setup_screen.dart';
import 'new_flow/screens/voice_setup_screen.dart';
import 'new_flow/screens/complete_screen.dart';
import 'layout/main_layout.dart';
import 'new_flow/features/integrations/routes/google_integration_routes.dart';

import 'services/stripe_service.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) registerWebFileInputs();

  await SupabaseConfig.initialize();
  await SupabaseService.instance.initialize(
    supabaseUrl: SupabaseConfig.supabaseUrl,
    supabaseAnonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Initialize Stripe
  await StripeService.initialize();

  // Initialize GetX controllers
  Get.put(AuthController());

  // Initialize BalanceService for global balance management
  await BalanceService().initialize();

  runApp(const RealtorOSApp());
}

class RealtorOSApp extends StatefulWidget {
  const RealtorOSApp({super.key});

  @override
  State<RealtorOSApp> createState() => _RealtorOSAppState();
}

class _RealtorOSAppState extends State<RealtorOSApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _checkingAuth = true;
  bool _onboardingCompleted = false;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _initDeepLinks();
    // Listen for auth changes to update UI automatically
    SupabaseService.instance.client.auth.onAuthStateChange.listen((data) {
      debugPrint('🔔 [Main] Auth state changed: ${data.event}');
      if (data.event == AuthChangeEvent.passwordRecovery) {
        debugPrint('🔐 [Main] Password recovery event detected');
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => const ResetPasswordScreen(),
          ),
        );
      } else if (mounted) {
        _checkStatus();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    _sub = AppLinks().uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        log("Deep link: $uri");

        if (uri.host == 'payment-success') {
          final sessionId = uri.queryParameters['session_id'];

          if (sessionId != null) {
            verifyPayment(sessionId);
          }
        }

        if (uri.host == 'payment-cancel') {
          print("Payment cancelled");
        }
      }
    });
  }

  Future<void> verifyPayment(String sessionId) async {
    try {
      log("Verifying session: $sessionId");

      final response = await Supabase.instance.client.functions.invoke(
        'verify-payment', // your edge function name
        body: {
          'session_id': sessionId,
        },
      );

      if (response.data != null) {
        log("Payment verified: ${response.data}");

        // Navigate to success screen
        Navigator.pushNamed(context, '/payment-success');
      } else {
        log("Verification failed");
      }
    } catch (e) {
      log("Verification error: $e");
    }
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: _navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful!'),
        content: const Text('Your payment was successful and tokens have been added to your wallet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPaymentCancelledDialog() {
    showDialog(
      context: _navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Payment Cancelled'),
        content: const Text('Your payment was cancelled. No tokens were added to your wallet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkStatus() async {
    try {
      final session = SupabaseService.instance.client.auth.currentSession;
      debugPrint(
        '🔐 [Main] Auth check: ${session != null ? "logged in" : "not logged in"}',
      );
      
      if (session != null) {
        _onboardingCompleted = await OnboardingService.isOnboardingCompleted();
        debugPrint('📋 [Main] Onboarding completed: $_onboardingCompleted');
      }
    } catch (e) {
      debugPrint('⚠️ [Main] Error checking status: $e');
    }
    if (mounted) setState(() => _checkingAuth = false);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Realtor OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _checkingAuth
          ? const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator()),
            )
          : SupabaseService.instance.client.auth.currentSession == null
          ? LoginScreen(onLoginSuccess: () => _checkStatus())
          : !_onboardingCompleted
          ? Column(
              children: [
                const OnboardingScreen(),
                // New Flow Option
                Container(
                  margin: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/new_flow/welcome');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonGold,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Try New Onboarding Flow'),
                  ),
                ),
              ],
            )
          : MainLayoutWrapper(activeIndex: 0),
      routes: {
        // New flow routes
        '/new_flow/welcome': (context) => const NewFlowWelcomeScreen(),
        '/new_flow/setup_profile': (context) => const NewFlowProfileSetupScreen(),
        '/new_flow/brand_setup': (context) => const NewFlowBrandSetupScreen(),
        '/new_flow/voice_setup': (context) => const NewFlowVoiceSetupScreen(),
        '/new_flow/complete': (context) => const NewFlowCompleteScreen(),
        '/dashboard': (context) => const AgentWalletScreen(),
        // Google Integrations routes
        ...GoogleIntegrationRoutes.routes,
      },
    );
  }
}
