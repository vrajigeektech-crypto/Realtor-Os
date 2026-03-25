import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
class EmailVerificationScreen extends StatefulWidget {
  final String email;
  
  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;
  Timer? _verificationTimer;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final supabase = SupabaseService.instance.client;
        
        // Try to get current session to check if email is verified
        await supabase.auth.refreshSession();
        final currentUser = supabase.auth.currentUser;
        
        if (currentUser != null && currentUser.emailConfirmedAt != null) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _successMessage = 'Email verified successfully! Redirecting...';
            });
            
            // Wait a moment to show the success message
            await Future.delayed(const Duration(seconds: 2));
            
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          }
        }
      } catch (e) {
        // Ignore errors during periodic check
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final supabase = SupabaseService.instance.client;
      
      // Use the resend method for signup verification
      await supabase.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      
      setState(() {
        _successMessage = 'Verification email sent again. Please check your inbox.';
        _isResending = false;
      });
    } catch (e) {
      debugPrint('❌ [EmailVerification] Failed to resend: $e');
      setState(() {
        _errorMessage = 'Failed to resend verification email. Please try again.';
        _isResending = false;
      });
    }
  }

  void _goBackToLogin() {
    _verificationTimer?.cancel();
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFd4a574).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    size: 40,
                    color: Color(0xFFd4a574),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    color: Color(0xFFd4a574),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'We\'ve sent a verification email to:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  widget.email,
                  style: const TextStyle(
                    color: Color(0xFFd4a574),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'Please check your email and click the verification link to activate your account. After verification, you will be able to log in.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Loading indicator for automatic check
                if (_isLoading) ...[
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4a574)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Checking verification status...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                
                if (_successMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                    ),
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(color: Color(0xFF81C784), fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Resend Email Button
                ElevatedButton(
                  onPressed: _isResending ? null : _resendVerificationEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFFd4a574),
                    side: const BorderSide(color: Color(0xFFd4a574)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isResending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4a574)),
                          ),
                        )
                      : const Text(
                          'Resend Verification Email',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Back to Login Button
                TextButton(
                  onPressed: _goBackToLogin,
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
