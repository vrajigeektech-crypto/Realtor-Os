import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/supabase_service.dart';
import '../../services/onboarding_service.dart';
import '../screen_wrapper.dart';

/// Profile setup screen for the new onboarding flow
class NewFlowProfileSetupScreen extends StatefulWidget {
  const NewFlowProfileSetupScreen({super.key});

  @override
  State<NewFlowProfileSetupScreen> createState() => _NewFlowProfileSetupScreenState();
}

class _NewFlowProfileSetupScreenState extends State<NewFlowProfileSetupScreen> {
  bool _isLoading = false;

  String get screenTitle => 'Profile Setup';
  double get progress => 0.2;
  bool get showSkipButton => false;

  // Controllers and state variables
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _licenseController = TextEditingController();
  String? _experienceLevel;
  String? _primaryMarket;

  @override
  Widget build(BuildContext context) {
    return NewFlowScreenWrapper(
      screenTitle: screenTitle,
      progress: progress,
      showSkipButton: showSkipButton,
      isLoading: _isLoading,
      onNext: () => _handleNext(context),
      child: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Let\'s set up your profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'This information helps us personalize your experience',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                hint: 'Enter your first name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                hint: 'Enter your last name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _licenseController,
                label: 'Real Estate License Number',
                hint: 'Enter your license number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your license number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildDropdownField(
                label: 'Experience Level',
                value: _experienceLevel,
                items: const [
                  'Less than 1 year',
                  '1-3 years',
                  '3-5 years',
                  '5-10 years',
                  '10+ years',
                ],
                onChanged: (value) {
                  setState(() => _experienceLevel = value);
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildDropdownField(
                label: 'Primary Market',
                value: _primaryMarket,
                items: const [
                  'Residential',
                  'Commercial',
                  'Luxury',
                  'Investment Properties',
                  'Mixed',
                ],
                onChanged: (value) {
                  setState(() => _primaryMarket = value);
                },
              ),
              
              const SizedBox(height: 32),
              
              _buildBrokerageSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintStyle: const TextStyle(color: AppColors.textMuted),
          ),
          style: const TextStyle(color: AppColors.textPrimary),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: const Text(
                'Select an option',
                style: TextStyle(color: AppColors.textMuted),
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              isExpanded: true,
              dropdownColor: AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrokerageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentBrown.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.buttonGold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Brokerage Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'You can add brokerage details later in settings',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // Navigate to brokerage setup
            },
            child: const Text(
              'Set Up Brokerage →',
              style: TextStyle(color: AppColors.buttonGold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        // Save profile data
        final user = SupabaseService.instance.client.auth.currentUser;
        if (user != null) {
          await OnboardingService.updateOnboardingData({
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'license_number': _licenseController.text,
            'experience_level': _experienceLevel,
            'primary_market': _primaryMarket,
            'onboarding_step': 1,
          });
        }
        
        // Navigate to next screen
        Navigator.of(context).pushNamed('/new_flow/brand_setup');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _licenseController.dispose();
    super.dispose();
  }
}
