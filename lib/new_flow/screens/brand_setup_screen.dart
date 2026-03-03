import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../screen_wrapper.dart';

/// Brand setup screen for the new onboarding flow
class NewFlowBrandSetupScreen extends StatefulWidget {
  const NewFlowBrandSetupScreen({super.key});

  @override
  State<NewFlowBrandSetupScreen> createState() => _NewFlowBrandSetupScreenState();
}

class _NewFlowBrandSetupScreenState extends State<NewFlowBrandSetupScreen> {
  bool _isLoading = false;

  String get screenTitle => 'Brand Setup';
  double get progress => 0.4;
  bool get showSkipButton => true;

  // State variables
  bool _logoSelected = false;
  String? _selectedVoice;
  Color? _selectedColor;

  @override
  Widget build(BuildContext context) {
    return NewFlowScreenWrapper(
      screenTitle: screenTitle,
      progress: progress,
      showSkipButton: showSkipButton,
      isLoading: _isLoading,
      onSkip: () => _handleSkip(context),
      onNext: () => _handleNext(context),
      child: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Build your brand identity',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Upload your logo and define your brand voice',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 32),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildLogoUploadSection(),
                  const SizedBox(height: 32),
                  _buildBrandVoiceSection(),
                  const SizedBox(height: 32),
                  _buildColorSchemeSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentBrown.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Company Logo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          GestureDetector(
            onTap: _pickLogo,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _logoSelected 
                      ? AppColors.buttonGold 
                      : AppColors.accentBrown.withOpacity(0.3),
                  style: _logoSelected ? BorderStyle.solid : BorderStyle.solid,
                ),
              ),
              child: _logoSelected 
                  ? _buildLogoPreview()
                  : _buildLogoUploadPlaceholder(),
            ),
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            'Recommended: Square logo, minimum 400x400px',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 40,
          color: AppColors.textMuted,
        ),
        const SizedBox(height: 8),
        Text(
          'Upload Logo',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PNG or JPG',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoPreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.buttonGold.withOpacity(0.1),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppColors.buttonGold, size: 32),
            SizedBox(height: 8),
            Text(
              'Logo Uploaded',
              style: TextStyle(
                color: AppColors.buttonGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandVoiceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentBrown.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Brand Voice',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ...['Professional', 'Friendly', 'Authoritative', 'Casual'].map((voice) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RadioListTile<String>(
                title: Text(
                  voice,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                value: voice,
                groupValue: _selectedVoice,
                onChanged: (value) {
                  setState(() => _selectedVoice = value);
                },
                activeColor: AppColors.buttonGold,
                contentPadding: EdgeInsets.zero,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildColorSchemeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentBrown.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color Scheme',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildColorOption(AppColors.buttonGold, 'Gold'),
              _buildColorOption(AppColors.roseGold, 'Rose Gold'),
              _buildColorOption(Colors.blue, 'Blue'),
              _buildColorOption(Colors.green, 'Green'),
              _buildColorOption(Colors.purple, 'Purple'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(Color color, String name) {
    final isSelected = _selectedColor == color;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? AppColors.textPrimary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _pickLogo() {
    // TODO: Implement image picker
    setState(() => _logoSelected = true);
  }

  Future<void> _handleNext(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      // Save brand settings and navigate
      Navigator.of(context).pushNamed('/new_flow/voice_setup');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSkip(BuildContext context) async {
    Navigator.of(context).pushNamed('/new_flow/voice_setup');
  }
}
