import 'dart:developer';

import 'package:demo/admin_pannel/admin_main_screen.dart';
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
import 'admin_pannel/admin_login_screen.dart';
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
import 'screens/oauth_callback_screen.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
// Path-based URL strategy for Flutter Web — removes the '#' from all URLs.
// This is required because OAuth 2.0 (RFC 6749) forbids fragment components
// in redirect_uri values, so https://domain/oauth/callback is used instead
// of https://domain/#/oauth/callback.
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Must be called before runApp() to take effect.
  if (kIsWeb) usePathUrlStrategy();

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
          MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
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
      if (uri == null) return;
      log("Deep link: $uri");

      if (uri.host == 'payment-success') {
        final sessionId = uri.queryParameters['session_id'];
        if (sessionId != null) {
          verifyPayment(sessionId);
        }
      }

      if (uri.host == 'payment-cancel') {
        log("Payment cancelled");
      }

      // Follow Up Boss OAuth success
      if (uri.host == 'fub-success') {
        log("FUB OAuth success deep link received");
        _showFubOAuthSuccessSnackBar();
      }

      // Generic OAuth callback (error path)
      if (uri.host == 'oauth-callback') {
        final error = uri.queryParameters['error'];
        if (error != null && error.isNotEmpty) {
          log("OAuth callback error: $error");
          _showOAuthErrorSnackBar(error);
        }
      }
    });
  }

  void _showFubOAuthSuccessSnackBar() {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text('Follow Up Boss connected successfully!'),
        backgroundColor: Color(0xFF10b981),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showOAuthErrorSnackBar(String error) {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('OAuth error: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> verifyPayment(String sessionId) async {
    try {
      log("Verifying session: $sessionId");

      final response = await Supabase.instance.client.functions.invoke(
        'verify-payment', // your edge function name
        body: {'session_id': sessionId},
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
        content: const Text(
          'Your payment was successful and tokens have been added to your wallet.',
        ),
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
        content: const Text(
          'Your payment was cancelled. No tokens were added to your wallet.',
        ),
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

    // After the main layout is ready, handle Flutter Web deep links.
    // Supports both path-based routing (/oauth/callback  ← production)
    // and hash-based routing (/#/oauth/callback ← fallback / legacy).
    if (kIsWeb) {
      final path = Uri.base.path;       // path-based: "/oauth/callback"
      final fragment = Uri.base.fragment; // hash-based: "/oauth/callback?code=..."

      final isOAuthCallback = path == '/oauth/callback' ||
          fragment.startsWith('/oauth/callback');
      final isFubSuccess =
          path == '/fub-success' || fragment.startsWith('/fub-success');

      if (isOAuthCallback) {
        // FUB redirected back to this app with an authorization code.
        // Push OAuthCallbackScreen on top of the home widget so the user
        // can pop back to the main app after a successful connection.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigatorKey.currentState?.pushNamed('/oauth/callback');
        });
      } else if (isFubSuccess) {
        // Legacy deep-link path from fub-callback edge function (mobile flow).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFubOAuthSuccessSnackBar();
        });
      }
    }
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
          // ? AdminLoginScreen()
          ? LoginScreen(onLoginSuccess: () => _checkStatus())
          : !_onboardingCompleted
          ? Expanded(child: OnboardingScreen())
          // : AdminLoginScreen(),
          // : AdminMainScreen(),
          : MainLayoutWrapper(activeIndex: 0),
      routes: {
        '/admin_login': (context) => const AdminLoginScreen(),
        // Follow Up Boss Web OAuth callback
        '/oauth/callback': (context) => const OAuthCallbackScreen(),
        // New flow routes
        '/new_flow/welcome': (context) => const NewFlowWelcomeScreen(),               
        '/new_flow/setup_profile': (context) =>       
            const NewFlowProfileSetupScreen(),                                                      
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
