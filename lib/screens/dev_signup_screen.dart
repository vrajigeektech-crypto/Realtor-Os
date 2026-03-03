import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/google_auth_service.dart';
import 'onboarding_screen.dart';

// DEV ONLY - REMOVE BEFORE PRODUCTION
class DevSignupScreen extends StatefulWidget {
  const DevSignupScreen({super.key});

  @override
  State<DevSignupScreen> createState() => _DevSignupScreenState();
}

class _DevSignupScreenState extends State<DevSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate password match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = SupabaseService.instance.client;
      final email = _emailController.text.trim();
      
      debugPrint('🔐 [Dev Signup] Attempting sign up for: $email');
      
      // Create auth user
      final response = await supabase.auth.signUp(
        email: email,
        password: _passwordController.text,
      );

      final session = response.session;
      final user = response.user;

      if (user == null) {
        debugPrint('❌ [Dev Signup] Sign up succeeded but user is null');
        setState(() {
          _errorMessage = 'Sign up failed: No user created. Please try again.';
          _isLoading = false;
        });
        return;
      }

      debugPrint('✅ [Dev Signup] Auth user created: ${user.id}');
      
      // Upsert into public.users table
      try {
        await supabase.from('users').upsert(
          {
            'id': user.id,
            'email': email,
            'role': 'agent',
            'status': 'active',
            'onboarded': false,
            'onboarding_completed': false,
            'onboarding_step': 0,
            'is_deleted': false,
            'created_at': DateTime.now().toIso8601String(),
            'joined_at': DateTime.now().toIso8601String(),
            'last_activity_date': DateTime.now().toIso8601String(),
            'gallery_count': 0,
          },
          onConflict: 'id',
        );
        debugPrint('✅ [Dev Signup] public.users record created/updated');
      } catch (dbError) {
        debugPrint('❌ [Dev Signup] Database upsert error: $dbError');
        // Continue anyway - user is authenticated
      }

      // Wait for session if not immediately available
      if (session == null) {
        debugPrint('⚠️ [Dev Signup] No session immediately available, waiting...');
        await Future.delayed(const Duration(seconds: 1));
        
        // Try to get current session
        final currentSession = supabase.auth.currentSession;
        if (currentSession == null) {
          debugPrint('❌ [Dev Signup] Still no session after wait');
          setState(() {
            _errorMessage = 'Sign up succeeded but session not available. Please try logging in.';
            _isLoading = false;
          });
          return;
        }
      }

      debugPrint('✅ [Dev Signup] Sign up successful');
      debugPrint('   - User ID: ${user.id}');
      debugPrint('   - Email: ${user.email}');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [Dev Signup] Sign up failed: $e');
      debugPrint('   Error type: ${e.runtimeType}');
      
      String userMessage = 'Sign up failed. Please try again.';
      
      final errorString = e.toString();
      
      if (errorString.contains('User already registered') || errorString.contains('already exists')) {
        userMessage = 'An account with this email already exists. Please log in instead.';
      } else if (errorString.contains('Invalid email')) {
        userMessage = 'Please enter a valid email address.';
      } else if (errorString.contains('Password')) {
        userMessage = 'Password is too weak. Please use a stronger password.';
      } else {
        final cleanError = errorString
            .replaceAll('Exception: ', '')
            .replaceAll('AuthException: ', '')
            .replaceAll('AuthRetryableFetchException: ', '')
            .replaceAll('message: ', '');
        
        if (cleanError.contains('"message"')) {
          try {
            final messageMatch = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(cleanError);
            if (messageMatch != null) {
              userMessage = messageMatch.group(1) ?? userMessage;
            }
          } catch (_) {
            // Fall back to default
          }
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
        debugPrint('✅ [Google] Sign-in successful for signup');
        
        // Create user record in database if needed
        final user = result.authResponse.user;
        if (user != null) {
          try {
            final supabase = SupabaseService.instance.client;
            await supabase.from('users').upsert(
              {
                'id': user.id,
                'email': user.email,
                'role': 'agent',
                'status': 'active',
                'onboarded': false,
                'onboarding_completed': false,
                'onboarding_step': 0,
                'is_deleted': false,
                'created_at': DateTime.now().toIso8601String(),
                'joined_at': DateTime.now().toIso8601String(),
                'last_activity_date': DateTime.now().toIso8601String(),
                'gallery_count': 0,
              },
              onConflict: 'id',
            );
            debugPrint('✅ [Google] User record created/updated in database');
          } catch (dbError) {
            debugPrint('⚠️ [Google] Database upsert error: $dbError');
          }
        }
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const OnboardingScreen(),
            ),
          );
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
                    'DEV SIGN UP – REMOVE BEFORE PRODUCTION',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Color(0xFFd4a574),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  //
                  // /// Google Sign-In Button
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
                  //                         image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                  //                         fit: BoxFit.contain,
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   const SizedBox(width: 12),
                  //                   const Text(
                  //                     'Sign up with Google',
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
                  //
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
                        return 'Please enter a password';
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
                      labelText: 'Confirm Password',
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
                        return 'Please confirm your password';
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
                  
                  const SizedBox(height: 32),
                  
                  // Create Account Button
                  ElevatedButton(
                    onPressed: (_isLoading || _isGoogleLoading) ? null : _handleSignup,
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
                            'Create Account',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Back to Login Button
                  TextButton(
                    onPressed: (_isLoading || _isGoogleLoading)
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
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
