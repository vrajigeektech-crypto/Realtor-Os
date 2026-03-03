import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final supabase = SupabaseService.instance.client;
      final newPassword = _passwordController.text;

      debugPrint('🔐 [ResetPassword] Updating password...');

      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      debugPrint('✅ [ResetPassword] Password updated successfully');

      setState(() {
        _successMessage = 'Your password has been reset successfully. You can now login with your new password.';
        _isLoading = false;
      });

      // Optionally redirect to login after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    } catch (e) {
      debugPrint('❌ [ResetPassword] Failed to update password: $e');

      String userMessage = 'Failed to update password. Please try again.';
      final errorString = e.toString();

      if (errorString.contains('Network') || errorString.contains('connection')) {
        userMessage = 'Network error. Please check your internet connection.';
      } else {
        final cleanError = errorString
            .replaceAll('Exception: ', '')
            .replaceAll('AuthException: ', '')
            .replaceAll('message: ', '');
        
        if (cleanError.contains('"message"')) {
          try {
            final messageMatch = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(cleanError);
            if (messageMatch != null) {
              userMessage = messageMatch.group(1) ?? userMessage;
            }
          } catch (_) {}
        } else if (cleanError.length < 100) {
          userMessage = cleanError;
        }
      }

      setState(() {
        _errorMessage = userMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        automaticallyImplyLeading: false, // Don't allow going back during reset
        title: const Text(
          'Set New Password',
          style: TextStyle(
            color: Color(0xFFd4a574),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.vpn_key_outlined,
                    size: 80,
                    color: Color(0xFFd4a574),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Reset Your Password',
                    style: TextStyle(
                      color: Color(0xFFd4a574),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Please enter a new password for your account.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // New Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFd4a574)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    enabled: !_isLoading && _successMessage == null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFd4a574)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    enabled: !_isLoading && _successMessage == null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
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
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Update Password Button
                  ElevatedButton(
                    onPressed: (_isLoading || _successMessage != null) ? null : _handleUpdatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFd4a574),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Update Password',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  
                  if (_successMessage != null) ...[
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(
                          color: Color(0xFFd4a574),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
