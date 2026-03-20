// lib/widgets/fub_connect_button.dart
//
// A self-contained "Connect Follow Up Boss" button widget.
//
// On Flutter Web  → calls FollowUpBossAuthService.initiateAuthForWeb()
//                   which performs a full-page redirect to FUB's authorize URL.
// On mobile/desktop → calls the existing initiateAuth() (external browser +
//                   deep-link return).
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/followupboss_auth_service.dart';

class FubConnectButton extends StatefulWidget {
  /// Invoked after the redirect is *initiated* (not after OAuth completes).
  /// On web the page will navigate away immediately after this fires.
  final VoidCallback? onInitiated;

  /// Optional label override; defaults to "Connect".
  final String label;

  const FubConnectButton({
    super.key,
    this.onInitiated,
    this.label = 'Connect',
  });

  @override
  State<FubConnectButton> createState() => _FubConnectButtonState();
}

class _FubConnectButtonState extends State<FubConnectButton> {
  bool _loading = false;
  final _service = FollowUpBossAuthService();

  Future<void> _onTap() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      // On web: fetches the OAuth URL from fub-auth edge function, then
      // uses dart:html window.location.href to redirect the browser.
      // On mobile: opens the OAuth URL in an external browser.
      if (kIsWeb) {
        await _service.initiateAuthForWeb();
      } else {
        await _service.initiateAuth();
      }
      widget.onInitiated?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _loading ? null : _onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white.withOpacity(0.25)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        disabledForegroundColor: Colors.white38,
      ),
      child: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white54,
              ),
            )
          : Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}
