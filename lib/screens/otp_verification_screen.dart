import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/otp_service.dart';
import 'new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String? otpType; // 'recovery' for password reset, 'signup' for email verification
  
  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.otpType = 'recovery',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;
  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Auto-verify when all fields are filled
    if (value.isNotEmpty && _getOtpCode().length == 6) {
      _verifyOtp();
    }
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
    });
    
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    final otpCode = _getOtpCode();
    
    if (otpCode.length != 6) {
      setState(() {
        _errorMessage = 'Please enter the 6-digit verification code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      if (widget.otpType == 'recovery') {
        await OtpService.verifyPasswordRecoveryOtp(widget.email, otpCode);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => NewPasswordScreen(
              email: widget.email,
              resetOtp: otpCode,
            ),
          ),
        );
      } else {
        // For email signup, use Supabase's verifyOTP
        final supabase = SupabaseService.instance.client;
        final response = await supabase.auth.verifyOTP(
          email: widget.email,
          token: otpCode,
          type: OtpType.signup,
        );
        
        if (response.session != null) {
          debugPrint('✅ [OTP] Email verification successful');
          
          setState(() {
            _successMessage = 'Email verified successfully!';
            _isLoading = false;
          });
          
          // Redirect to login after a delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          });
        } else {
          throw Exception('Invalid verification code');
        }
      }
    } catch (e) {
      debugPrint('❌ [OTP] Verification failed: $e');
      setState(() {
        _errorMessage = 'Invalid or expired verification code. Please try again.';
        _isLoading = false;
      });
      
      // Clear OTP fields
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;
    
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      if (widget.otpType == 'recovery') {
        await OtpService.sendPasswordRecoveryEmail(widget.email);

        setState(() {
          _successMessage =
              'A new code has been sent to your email if an account exists.';
          _isResending = false;
        });
      } else {
        // Resend OTP for email signup using Supabase
        final supabase = SupabaseService.instance.client;
        await supabase.auth.resend(
          type: OtpType.signup,
          email: widget.email,
        );
        
        setState(() {
          _successMessage = 'Verification code sent again. Please check your email.';
          _isResending = false;
        });
      }
      
      _startResendTimer();
      
      // Clear OTP fields
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    } catch (e) {
      debugPrint('❌ [OTP] Failed to resend: $e');
      setState(() {
        _errorMessage = 'Failed to resend verification code. Please try again.';
        _isResending = false;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFd4a574)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.otpType == 'recovery' ? 'Verify Recovery Code' : 'Verify Email',
          style: const TextStyle(
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
                    Icons.security_outlined,
                    size: 40,
                    color: Color(0xFFd4a574),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  widget.otpType == 'recovery' 
                      ? 'Enter Recovery Code'
                      : 'Enter Verification Code',
                  style: const TextStyle(
                    color: Color(0xFFd4a574),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  widget.otpType == 'recovery'
                      ? 'We\'ve sent a 6-digit recovery code to your email. Enter it below.'
                      : 'We\'ve sent a 6-digit verification code to your email.',
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
                
                const SizedBox(height: 32),
                
                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      height: 55,
                      child: TextFormField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFd4a574),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                        ),
                        enabled: !_isLoading,
                        onChanged: (value) => _onOtpChanged(index, value),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 32),
                
                if (_errorMessage != null) ...[
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
                  const SizedBox(height: 16),
                ],
                
                if (_successMessage != null) ...[
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
                  const SizedBox(height: 16),
                ],
                
                // Verify Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
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
                          'Verify Code',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Resend Button
                TextButton(
                  onPressed: _isResending || _resendCountdown > 0 ? null : _resendOtp,
                  child: _isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4a574)),
                          ),
                        )
                      : Text(
                          _resendCountdown > 0
                              ? 'Resend Code ($_resendCountdown)'
                              : 'Resend Code',
                          style: TextStyle(
                            color: _resendCountdown > 0
                                ? Colors.white.withOpacity(0.5)
                                : const Color(0xFFd4a574),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Back to Login
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).popUntil((route) => route.isFirst),
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
