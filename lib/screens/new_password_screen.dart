import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth_app_bridge.dart';
import '../auth_recovery_launch.dart';
import '../services/supabase_service.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;

  /// When set, password is applied via Edge Function (OTP flow — no Supabase Auth recovery).
  /// When null, expects an existing recovery session (email reset link → implicit tokens).
  final String? resetOtp;

  const NewPasswordScreen({
    super.key,
    required this.email,
    this.resetOtp,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
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

      debugPrint('🔐 [NewPassword] Updating password for: ${widget.email}');

      if (widget.resetOtp != null) {
        final response = await supabase.functions.invoke(
          'forgot-password-complete',
          body: {
            'email': widget.email.trim(),
            'otp': widget.resetOtp,
            'new_password': newPassword,
          },
        );
        if (response.status != 200) {
          final data = response.data;
          final msg = data is Map && data['error'] != null
              ? data['error'].toString()
              : 'Failed to update password';
          throw Exception(msg);
        }
      } else {
        await supabase.auth.updateUser(
          UserAttributes(password: newPassword),
        );
      }

      debugPrint('✅ [NewPassword] Password updated successfully');

      AuthRecoveryLaunch.clear();

      setState(() {
        _successMessage = 'Your password has been reset successfully!';
        _isLoading = false;
      });

      Future.delayed(const Duration(seconds: 2), () async {
        if (!mounted) return;
        await refreshAppAfterAuth?.call();
        if (!mounted) return;
        resetNavigatorToMatchHome();
      });
    } on FunctionException catch (e) {
      debugPrint('❌ [NewPassword] FunctionException: ${e.status} ${e.details}');
      String userMessage = 'Failed to update password. Please try again.';
      final d = e.details;
      if (d is Map && d['error'] != null) {
        userMessage = d['error'].toString();
      }
      setState(() {
        _errorMessage = userMessage;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ [NewPassword] Failed to update password: $e');

      String userMessage = 'Failed to update password. Please try again.';
      final errorString = e.toString();

      if (errorString.contains('Network') || errorString.contains('connection')) {
        userMessage = 'Network error. Please check your internet connection.';
      } else if (errorString.contains('weak password')) {
        userMessage = 'Password is too weak. Please choose a stronger password.';
      } else if (errorString.contains('same password')) {
        userMessage = 'New password must be different from your current password.';
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
        automaticallyImplyLeading: false, // Don't allow going back during password reset
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
                  // Success Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFd4a574).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 40,
                      color: Color(0xFFd4a574),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Create New Password',
                    style: TextStyle(
                      color: Color(0xFFd4a574),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Your identity has been verified. Please create a new password for your account.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    widget.email,
                    style: const TextStyle(
                      color: Color(0xFFd4a574),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // New Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFd4a574)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: !_showPassword,
                    enabled: !_isLoading && _successMessage == null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
                        return 'Password must contain both letters and numbers';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFd4a574)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: !_showConfirmPassword,
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
                  
                  // Password Requirements
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password Requirements:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...[
                          'At least 6 characters long',
                          'Contains both letters and numbers',
                          'Different from your current password',
                        ].map((requirement) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  requirement,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  
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
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: const TextStyle(color: Colors.green, fontSize: 12),
                            ),
                          ),
                        ],
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
