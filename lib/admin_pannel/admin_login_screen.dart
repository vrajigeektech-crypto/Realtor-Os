import 'package:demo/admin_pannel/admin_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedRole;
  bool _isDropdownOpen = false;
  bool _isPasswordObscured = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const List<String> _roles = [
    'Super Admin',
    'Ops Admin',
    'Content Reviewer',
    'Fulfillment Admin',
  ];

  // Color palette extracted from the design
  static const Color _bgDark = Color(0xFF1C1C1C);
  static const Color _bgCard = Color(0xFF252525);
  static const Color _inputBg = Color(0xFF2A2A2A);
  static const Color _inputBorder = Color(0xFF3A3A3A);
  static const Color _dropdownBg = Color(0xFF2C2C2C);
  static const Color _dropdownItemBg = Color(0xFF303030);
  static const Color _accentRed = Color(0xFFC0524A);
  static const Color _accentRedLight = Color(0xFFD4685F);
  static const Color _accentRedDark = Color(0xFF8B3A34);
  static const Color _textPrimary = Color(0xFFE8E8E8);
  static const Color _textHint = Color(0xFF888888);
  static const Color _dividerColor = Color(0xFF3A3A3A);
  static const Color _redLine = Color(0xFF9B3A35);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dark textured background
          _buildBackground(),

          // Main content
          Column(
            children: [
              // Top red accent line
              Container(height: 1.5, color: _redLine),

              // Title bar
              _buildTitleBar(),

              // Red separator line
              Container(height: 1.5, color: _redLine),

              // Body
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildLoginForm(),
                    ),
                  ),
                ),
              ),

              // Bottom red accent line
              Container(height: 1.5, color: _redLine),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [
            Color(0xFF252525),
            Color(0xFF161616),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _HexPatternPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: const Text(
        'Realtor OS Admin Portal',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _textPrimary,
          fontSize: 30,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          fontFamily: 'Georgia',
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width: 460,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Email field
          _buildTextField(
            controller: _emailController,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Password field
          _buildTextField(
            controller: _passwordController,
            hint: 'Password',
            obscureText: _isPasswordObscured,
            suffixIcon: GestureDetector(
              onTap: () =>
                  setState(() => _isPasswordObscured = !_isPasswordObscured),
              child: Icon(
                _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                color: _textHint,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Role dropdown
          _buildRoleDropdown(),
          const SizedBox(height: 20),

          // Login button
          _buildLoginButton(),
          SizedBox(height: 24),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/login');
            },
            child: Text(
              'Login As User',
              style: TextStyle(
                color: Colors.orange.withValues(alpha: 0.7),
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _inputBorder, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 15,
          fontFamily: 'Georgia',
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: _textHint,
            fontSize: 15,
            fontFamily: 'Georgia',
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      children: [
        // Dropdown trigger
        GestureDetector(
          onTap: () => setState(() => _isDropdownOpen = !_isDropdownOpen),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: _inputBg,
              borderRadius: _isDropdownOpen
                  ? const BorderRadius.vertical(top: Radius.circular(6))
                  : BorderRadius.circular(6),
              border: Border.all(
                color: _isDropdownOpen ? _accentRed : _inputBorder,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedRole ?? 'Select Role',
                  style: TextStyle(
                    color: _selectedRole != null ? _textPrimary : _textHint,
                    fontSize: 15,
                    fontFamily: 'Georgia',
                  ),
                ),
                AnimatedRotation(
                  turns: _isDropdownOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: _textHint,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Dropdown menu
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: _isDropdownOpen ? (_roles.length * 52.0) : 0,
          child: ClipRRect(
            borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(6)),
            child: Container(
              decoration: BoxDecoration(
                color: _dropdownBg,
                border: Border(
                  left: BorderSide(color: _accentRed, width: 1),
                  right: BorderSide(color: _accentRed, width: 1),
                  bottom: BorderSide(
                    color: _isDropdownOpen ? _accentRed : Colors.transparent,
                    width: 1,
                  ),
                ),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _roles.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 1, color: _dividerColor),
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  final isSelected = _selectedRole == role;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedRole = role;
                        _isDropdownOpen = false;
                      });
                    },
                    child: Container(
                      height: 52,
                      color: isSelected
                          ? _accentRedDark.withOpacity(0.2)
                          : _dropdownItemBg,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        role,
                        style: TextStyle(
                          color: isSelected ? _accentRedLight : _textPrimary,
                          fontSize: 15,
                          fontFamily: 'Georgia',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFBF5248),
              Color(0xFF9B3A35),
              Color(0xFF7A2D29),
            ],
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: _accentRedDark.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text(
            'Login',
            style: TextStyle(
              color: Color(0xFFEEEEEE),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.2,
              fontFamily: 'Georgia',
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty) {
      _showSnack('Please enter your email');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showSnack('Please enter your password');
      return;
    }
    if (_selectedRole == null) {
      _showSnack('Please select a role');
      return;
    }

    // Only allow Super Admin to login
    if (_selectedRole == 'Super Admin') {
      await _authenticateSuperAdmin();
    } else {
      _showSnack('Access denied. Only Super Admin can log in.');
    }
  }

  Future<void> _authenticateSuperAdmin() async {
    const String superAdminEmail = 'superadmin@gmail.com';
    const String superAdminPassword = '111111';

    if (_emailController.text != superAdminEmail || _passwordController.text != superAdminPassword) {
      _showSnack('Invalid Super Admin credentials');
      return;
    }

    try {
      _showSnack('Authenticating Super Admin...');
      
      // Initialize Supabase if not already initialized
      User? user;
      if (SupabaseService.instance.client.auth.currentUser == null) {
        // Sign in with Supabase using the specific credentials
        final response = await SupabaseService.instance.client.auth.signInWithPassword(
          email: superAdminEmail,
          password: superAdminPassword,
        );

        if (response.user == null) {
          _showSnack('Super Admin authentication failed');
          return;
        }
        user = response.user;
      } else {
        user = SupabaseService.instance.client.auth.currentUser;
      }

      // ✅ Flutter Check for Super Admin
      if (user?.email == "superadmin@gmail.com" &&
          user?.userMetadata?['is_super_admin'] == true) {
        // Open Super Admin Panel
        _showSnack('Super Admin authentication successful');
        
        // Update user metadata to ensure Super Admin role is set
        await SupabaseService.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              'role': 'Super Admin',
              'is_super_admin': true,
            },
          ),
        );
        
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminMainScreen()));
        }
      } else {
        // Update metadata if not already set
        await SupabaseService.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              'role': 'Super Admin',
              'is_super_admin': true,
            },
          ),
        );
        
        // Check again after updating metadata
        final updatedUser = SupabaseService.instance.client.auth.currentUser;
        if (updatedUser?.email == "superadmin@gmail.com" &&
            updatedUser?.userMetadata?['is_super_admin'] == true) {
          _showSnack('Super Admin authentication successful');
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminMainScreen()));
          }
        } else {
          _showSnack('Super Admin access denied. Insufficient privileges.');
        }
      }
    } catch (e) {
      _showSnack('Super Admin authentication error: $e');
    }
  }

  Future<void> _authenticateRegularAdmin() async {
    try {
      _showSnack('Authenticating as $_selectedRole...');
      
      // Sign in with Supabase using provided credentials
      final response = await SupabaseService.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user == null) {
        _showSnack('Invalid credentials for $_selectedRole');
        return;
      }

      // Check if user exists and is confirmed
      final user = response.user!;
      if (user.emailConfirmedAt == null) {
        _showSnack('Please confirm your email first');
        return;
      }

      // Update user metadata with the selected role
      await SupabaseService.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'role': _selectedRole,
            'selected_role_at': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      _showSnack('Successfully logged in as $_selectedRole');
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminMainScreen()));
      }
    } catch (e) {
      _showSnack('Authentication failed: Invalid email or password');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(fontFamily: 'Georgia', color: _textPrimary)),
        backgroundColor: _dropdownBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: _accentRed, width: 1),
        ),
      ),
    );
  }
}

/// Custom painter for subtle hexagonal/dot pattern background
class _HexPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A2A2A).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    const double radius = 3.5;
    const double spacingX = 22;
    const double spacingY = 19;

    for (double y = 0; y < size.height + spacingY; y += spacingY) {
      final offset = (y ~/ spacingY % 2 == 0) ? 0.0 : spacingX / 2;
      for (double x = offset; x < size.width + spacingX; x += spacingX) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}