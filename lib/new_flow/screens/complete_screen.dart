import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/onboarding_service.dart';
import '../../services/supabase_service.dart';
import '../screen_wrapper.dart';

/// Completion screen for the new onboarding flow
class NewFlowCompleteScreen extends StatefulWidget {
  const NewFlowCompleteScreen({super.key});

  @override
  State<NewFlowCompleteScreen> createState() => _NewFlowCompleteScreenState();
}

class _NewFlowCompleteScreenState extends State<NewFlowCompleteScreen> {
  bool _isLoading = false;

  String get screenTitle => 'Setup Complete';
  double get progress => 1.0;
  bool get showBackButton => false;
  bool get showSkipButton => false;

  @override
  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          
          // Success animation container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.buttonGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: AppColors.buttonGold,
            ),
          ),
          
          const Spacer(),
          
          // Success message
          const Text(
            'You\'re all set!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Your Realtor OS account is ready to help you\ntransform your real estate business',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // What's next section
          _buildWhatsNextSection(),
          
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildWhatsNextSection() {
    return Container(
      width: double.infinity,
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
            'What\'s Next?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ...[
            _buildNextItem(
              icon: Icons.dashboard,
              title: 'Explore Dashboard',
              description: 'View your performance metrics',
            ),
            _buildNextItem(
              icon: Icons.leaderboard,
              title: 'Generate Leads',
              description: 'Start your first lead generation campaign',
            ),
            _buildNextItem(
              icon: Icons.auto_awesome,
              title: 'Automate Tasks',
              description: 'Set up automation for repetitive work',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.buttonGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.buttonGold,
              size: 20,
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
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.surfaceHigh,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.buttonGold),
            minHeight: 4,
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% Complete',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          screenTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: buildContent(context),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _goToDashboard(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonGold,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                        ),
                      )
                    : const Text(
                        'Go to Dashboard',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: _isLoading ? null : () => _takeTour(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.buttonGold,
                ),
                child: const Text(
                  'Take a Quick Tour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> onNext(BuildContext context) async {
    await _goToDashboard();
  }

  Future<void> _goToDashboard() async {
    setState(() => _isLoading = true);
    
    try {
      // Mark onboarding as complete
      await OnboardingService.completeOnboarding();
      
      // Navigate to main dashboard
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/dashboard',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing setup: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _takeTour() async {
    // TODO: Implement interactive tour
    setState(() => _isLoading = true);
    
    // Simulate tour setup
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      // Navigate to dashboard with tour flag
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/dashboard?tour=true',
        (route) => false,
      );
    }
  }
}
