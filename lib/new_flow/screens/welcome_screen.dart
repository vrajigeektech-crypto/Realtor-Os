import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../screen_wrapper.dart';

/// Welcome screen for the new onboarding flow
class NewFlowWelcomeScreen extends StatefulWidget {
  const NewFlowWelcomeScreen({super.key});

  @override
  State<NewFlowWelcomeScreen> createState() => _NewFlowWelcomeScreenState();
}

class _NewFlowWelcomeScreenState extends State<NewFlowWelcomeScreen> {
  bool _isLoading = false;

  String get screenTitle => 'Welcome';
  double get progress => 0.0;
  bool get showSkipButton => true;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          
          // Welcome illustration placeholder
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.real_estate_agent,
              size: 80,
              color: AppColors.buttonGold,
            ),
          ),
          
          const Spacer(),
          
          // Welcome text
          const Text(
            'Welcome to Realtor OS',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Your AI-powered real estate assistant\nis ready to transform your business',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Key features
          _buildFeatureRow(
            icon: Icons.auto_awesome,
            title: 'AI-Powered Automation',
            description: 'Automate repetitive tasks',
          ),
          
          const SizedBox(height: 16),
          
          _buildFeatureRow(
            icon: Icons.trending_up,
            title: 'Lead Generation',
            description: 'Generate qualified leads',
          ),
          
          const SizedBox(height: 16),
          
          _buildFeatureRow(
            icon: Icons.analytics,
            title: 'Performance Analytics',
            description: 'Track your success metrics',
          ),
          
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.buttonGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.buttonGold,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleNext(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      // Navigate to next screen in the flow
      Navigator.of(context).pushNamed('/new_flow/setup_profile');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSkip(BuildContext context) async {
    // Skip to main dashboard
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/dashboard',
      (route) => false,
    );
  }
}
