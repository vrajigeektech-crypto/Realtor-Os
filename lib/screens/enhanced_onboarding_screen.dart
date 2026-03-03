import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/onboarding_service.dart';
import 'company_info_screen.dart';
import 'brand_voice_setup_screen.dart';

enum OnboardingStage {
  welcome,
  companyInfo,
  brandAssets,
}

class EnhancedOnboardingScreen extends StatefulWidget {
  const EnhancedOnboardingScreen({super.key});

  @override
  State<EnhancedOnboardingScreen> createState() => _EnhancedOnboardingScreenState();
}

class _EnhancedOnboardingScreenState extends State<EnhancedOnboardingScreen> {
  OnboardingStage _currentStage = OnboardingStage.welcome;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStage() {
    switch (_currentStage) {
      case OnboardingStage.welcome:
        _navigateToStage(OnboardingStage.companyInfo);
        break;
      case OnboardingStage.companyInfo:
        _navigateToStage(OnboardingStage.brandAssets);
        break;
      case OnboardingStage.brandAssets:
        _completeOnboarding();
        break;
    }
  }

  void _navigateToStage(OnboardingStage stage) {
    setState(() {
      _currentStage = stage;
    });
    _pageController.animateToPage(
      stage.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    await OnboardingService.completeOnboarding();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStage = OnboardingStage.values[index];
                  });
                },
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomeScreen(),
                  CompanyInfoScreen(onSaveContinue: _nextStage),
                  BrandVoiceSetupScreen(onComplete: _nextStage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          _buildProgressStep(0, 'Welcome'),
          Expanded(child: _buildProgressLine(0)),
          _buildProgressStep(1, 'Company'),
          Expanded(child: _buildProgressLine(1)),
          _buildProgressStep(2, 'Brand'),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int index, String label) {
    final isActive = _currentStage.index >= index;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.buttonGold : AppColors.textMuted,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isActive ? Colors.black : AppColors.background,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.textPrimary : AppColors.textMuted,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(int index) {
    final isActive = _currentStage.index > index;
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.buttonGold : AppColors.textMuted,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.buttonGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.home,
              size: 60,
              color: AppColors.buttonGold,
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'Welcome to Realtor OS',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            'Let\'s set up your profile to get you started with the complete real estate management solution.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          const Text(
            'We\'ll help you:\n• Set up your company information\n• Upload your logo and headshot\n• Configure your brand voice\n• Add writing samples\n• Record voice samples',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _nextStage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
