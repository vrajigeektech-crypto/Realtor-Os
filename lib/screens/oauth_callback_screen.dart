// lib/screens/oauth_callback_screen.dart
//
// Handles the Follow Up Boss OAuth redirect for Flutter Web.
//
// ─── Flow ─────────────────────────────────────────────────────────────────────
//  1. User clicks Connect → fub-auth edge function returns a signed OAuth URL
//     containing redirect_uri = https://realtor--os.web.app/#/oauth/callback
//  2. Browser redirects to FUB; user grants access.
//  3. FUB redirects back to:
//       https://realtor--os.web.app/#/oauth/callback?code=AUTH_CODE&state=USER_ID
//  4. This screen reads `code` + `state` from Uri.base (dart:core, no dart:html needed).
//  5. POSTs { code, redirect_uri, state } to the `exchange-token` Supabase function.
//  6. Shows loading → success (snackbar + auto-return) or error (retry button).
// ──────────────────────────────────────────────────────────────────────────────
import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../services/followupboss_auth_service.dart';

// redirect_uri used in both the /authorize request AND the /token exchange.
// No '#' fragment (OAuth spec §3.1.2). MUST be registered in FUB app settings.
const String _kWebRedirectUri = FollowUpBossAuthService.kWebRedirectUri;

enum _OAuthState { loading, success, error }

class OAuthCallbackScreen extends StatefulWidget {
  const OAuthCallbackScreen({super.key});

  @override
  State<OAuthCallbackScreen> createState() => _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends State<OAuthCallbackScreen> {
  _OAuthState _state = _OAuthState.loading;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(_handleCallback);
  }

  // ---------------------------------------------------------------------------
  // Core OAuth logic
  // ---------------------------------------------------------------------------

  Future<void> _handleCallback() async {
    if (mounted) setState(() => _state = _OAuthState.loading);

    // Uri.base is the full browser URL on Flutter Web (dart:core — no dart:html).
    // URL format: https://realtor--os.web.app/#/oauth/callback?code=ABC&state=XYZ
    final code = _extractParam('code');
    final state = _extractParam('state');

    debugPrint('🔐 [OAuthCallback] code present: ${code != null}');
    debugPrint('🔐 [OAuthCallback] state: $state');

    if (code == null || code.isEmpty) {
      _setError('Authorization failed: no authorization code was received.\n'
          'Please try connecting again.');
      return;
    }

    try {
      // POST { code, redirect_uri, state } to the exchange-token edge function.
      // redirect_uri must exactly match what was sent in the /authorize request.
      await ApiService.exchangeToken(
        code: code,
        redirectUri: _kWebRedirectUri,
        state: state,
      );

      if (!mounted) return;
      setState(() => _state = _OAuthState.success);

      // Show success snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Follow Up Boss connected successfully!'),
          backgroundColor: Color(0xFF10b981),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Return to the main app after a short success display.
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      _navigateBack();
    } catch (e) {
      if (!mounted) return;
      _setError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ---------------------------------------------------------------------------
  // URL parsing
  //
  // Production (path-based routing, usePathUrlStrategy):
  //   https://realtor--os.web.app/oauth/callback?code=XYZ&state=USER_ID
  //   → Uri.base.queryParameters['code'] == 'XYZ'  ✓
  //
  // Legacy fallback (hash-based routing):
  //   https://realtor--os.web.app/#/oauth/callback?code=XYZ&state=USER_ID
  //   → params are inside Uri.base.fragment
  // ---------------------------------------------------------------------------

  String? _extractParam(String key) {
    final uri = Uri.base;

    // 1. Standard query string — the normal case with path-based URL strategy.
    //    FUB appends ?code=XYZ&state=USER_ID directly to the redirect_uri.
    final fromQuery = uri.queryParameters[key];
    if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;

    // 2. Fallback: query string embedded inside the URL hash fragment.
    //    fragment example: "/oauth/callback?code=ABC&state=XYZ"
    final fragment = uri.fragment;
    final qIdx = fragment.indexOf('?');
    if (qIdx == -1) return null;
    final fragParams = Uri.splitQueryString(fragment.substring(qIdx + 1));
    final fromFragment = fragParams[key];
    return (fromFragment != null && fromFragment.isNotEmpty) ? fromFragment : null;
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _navigateBack() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      // Fresh page-load on the callback URL — home widget hasn't been pushed.
      nav.pushNamedAndRemoveUntil('/dashboard', (route) => false);
    }
  }

  // ---------------------------------------------------------------------------
  // State helpers
  // ---------------------------------------------------------------------------

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _state = _OAuthState.error;
      _errorMessage = message;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _OAuthState.loading:
        return _LoadingView(key: const ValueKey('loading'));
      case _OAuthState.success:
        return _SuccessView(key: const ValueKey('success'));
      case _OAuthState.error:
        return _ErrorView(
          key: const ValueKey('error'),
          message: _errorMessage,
          onBack: _navigateBack,
          onRetry: _handleCallback,
        );
    }
  }
}

// =============================================================================
// Loading
// =============================================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            color: Color(0xFF10b981),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Connecting Follow Up Boss…',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Exchanging authorization code with Supabase…',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Success
// =============================================================================

class _SuccessView extends StatelessWidget {
  const _SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF10b981),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Connected Successfully!',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF10b981),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Follow Up Boss has been linked to your account.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Returning to the app…',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.35),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Error
// =============================================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  const _ErrorView({
    super.key,
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.shade800,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Connection Failed',
            style: TextStyle(
              fontSize: 24,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 32),
          // Retry button
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10b981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Go back button
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white70,
            ),
            label: const Text(
              'Go Back',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(0.25)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
