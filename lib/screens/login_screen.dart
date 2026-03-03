import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/supabase_service.dart';
import '../services/google_auth_service.dart';
import 'dev_signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  
  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = SupabaseService.instance.client;
      final email = _emailController.text.trim();
      
      debugPrint('🔐 [Login] Attempting sign in for: $email');
      
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: _passwordController.text,
      );

      final session = response.session;
      final user = response.user;
      
      if (session == null) {
        debugPrint('❌ [Login] Sign in succeeded but session is null');
        setState(() {
          _errorMessage = 'Login failed: No session created. Please try again.';
          _isLoading = false;
        });
        return;
      }

      debugPrint('✅ [Login] Sign in successful');
      debugPrint('   - User ID: ${user?.id ?? "null"}');
      debugPrint('   - Email: ${user?.email ?? "null"}');
      debugPrint('   - Access token exists: ${session.accessToken.isNotEmpty}');

      if (mounted) {
        widget.onLoginSuccess?.call();
      }
    } catch (e) {
      debugPrint('❌ [Login] Sign in failed: $e');
      
      String userMessage = 'Login failed. Please try again.';
      
      final errorString = e.toString();
      
      if (errorString.contains('500') || errorString.contains('Database error')) {
        userMessage = 'Server error: Database issue detected. Please contact support or try again later.';
      } else if (errorString.contains('401') || errorString.contains('Invalid login')) {
        userMessage = 'Invalid email or password. Please check your credentials.';
      } else if (errorString.contains('Network') || errorString.contains('connection')) {
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

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _googleAuthService.signInWithGoogle();
      
      if (result.success) {
        debugPrint('✅ [Google] Sign-in successful');
        if (mounted) {
          widget.onLoginSuccess?.call();
        }
      } else if (result.cancelled) {
        debugPrint('⚠️ [Google] Sign-in cancelled');
        setState(() {
          _isGoogleLoading = false;
        });
      } else {
        debugPrint('❌ [Google] Sign-in failed: ${result.error}');
        setState(() {
          _errorMessage = result.error ?? 'Google sign-in failed';
          _isGoogleLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [Google] Unexpected error: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred during Google sign-in';
        _isGoogleLoading = false;
      });
    }
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFFd4a574),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  /// Google Sign-In Button
                  // Container(
                  //   height: 50,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(8),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.1),
                  //         blurRadius: 4,
                  //         offset: const Offset(0, 2),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Material(
                  //     color: Colors.transparent,
                  //     child: InkWell(
                  //       borderRadius: BorderRadius.circular(8),
                  //       onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
                  //       child: Center(
                  //         child: _isGoogleLoading
                  //             ? const SizedBox(
                  //                 width: 20,
                  //                 height: 20,
                  //                 child: CircularProgressIndicator(
                  //                   strokeWidth: 2,
                  //                   valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF757575)),
                  //                 ),
                  //               )
                  //             : Row(
                  //                 mainAxisSize: MainAxisSize.min,
                  //                 children: [
                  //                   Container(
                  //                     width: 24,
                  //                     height: 24,
                  //                     decoration: const BoxDecoration(
                  //                       image: DecorationImage(
                  //                         image: AssetImage('assets/google_logo.png'),
                  //                         fit: BoxFit.contain,
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   const SizedBox(width: 12),
                  //                   const Text(
                  //                     'Sign in with Google',
                  //                     style: TextStyle(
                  //                       color: Color(0xFF757575),
                  //                       fontSize: 16,
                  //                       fontWeight: FontWeight.w500,
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // const SizedBox(height: 32),
                  //
                  // // Divider
                  // Row(
                  //   children: [
                  //     const Expanded(
                  //       child: Divider(color: Colors.white30, thickness: 1),
                  //     ),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 16),
                  //       child: Text(
                  //         'OR',
                  //         style: TextStyle(
                  //           color: Colors.white.withOpacity(0.7),
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.w500,
                  //         ),
                  //       ),
                  //     ),
                  //     const Expanded(
                  //       child: Divider(color: Colors.white30, thickness: 1),
                  //     ),
                  //   ],
                  // ),
                  //
                  const SizedBox(height: 32),
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFd4a574)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading && !_isGoogleLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
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
                    enabled: !_isLoading && !_isGoogleLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  
                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: (_isLoading || _isGoogleLoading)
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFFd4a574),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
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
                  
                  const SizedBox(height: 32),
                  
                  // Login Button
                  ElevatedButton(
                    onPressed: (_isLoading || _isGoogleLoading) ? null : _handleLogin,
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
                            'Login',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const SizedBox(height: 16),
                  
                  // Dev Signup Button
                  TextButton(
                    onPressed: (_isLoading || _isGoogleLoading)
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DevSignupScreen(),
                              ),
                            );
                          },
                    child: const Text(
                      'DEV: Create Account',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
