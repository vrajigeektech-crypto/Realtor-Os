import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/onboarding_service.dart';
import '../services/supabase_service.dart';
import 'logo_upload_screen.dart';
import 'add_photos_screen.dart';
import 'company_info_screen.dart';
import 'brand_voice_setup_screen.dart';
import 'record_script_screen.dart';
import 'market_place_screen.dart';

enum OnboardingStep {
  logoUpload,
  headshotUpload,
  companyInfo,
  voiceSample,
  writingSample,
  photosUpload,
}

class ComprehensiveOnboardingFlow extends StatefulWidget {
  const ComprehensiveOnboardingFlow({super.key});

  @override
  State<ComprehensiveOnboardingFlow> createState() => _ComprehensiveOnboardingFlowState();
}

class _ComprehensiveOnboardingFlowState extends State<ComprehensiveOnboardingFlow> {
  OnboardingStep _currentStep = OnboardingStep.logoUpload;
  final Set<OnboardingStep> _completedSteps = <OnboardingStep>{};

  bool get _isStepCompleted(OnboardingStep step) => _completedSteps.contains(step);
  
  double get _progress => _completedSteps.length / OnboardingStep.values.length;

  List<OnboardingStep> get _availableSteps {
    final steps = <OnboardingStep>[];
    
    // Logo upload is always available
    steps.add(OnboardingStep.logoUpload);
    
    // Headshot available after logo
    if (_isStepCompleted(OnboardingStep.logoUpload)) {
      steps.add(OnboardingStep.headshotUpload);
    }
    
    // Company info available after headshot
    if (_isStepCompleted(OnboardingStep.headshotUpload)) {
      steps.add(OnboardingStep.companyInfo);
    }
    
    // Voice sample available after company info
    if (_isStepCompleted(OnboardingStep.companyInfo)) {
      steps.add(OnboardingStep.voiceSample);
    }
    
    // Writing sample available after voice sample
    if (_isStepCompleted(OnboardingStep.voiceSample)) {
      steps.add(OnboardingStep.writingSample);
    }
    
    // Photos upload available after writing sample
    if (_isStepCompleted(OnboardingStep.writingSample)) {
      steps.add(OnboardingStep.photosUpload);
    }
    
    return steps;
  }

  void _markStepCompleted(OnboardingStep step) {
    setState(() {
      _completedSteps.add(step);
      debugPrint('✅ [Onboarding] Step completed: ${step.name}');
    });
  }

  void _navigateToStep(OnboardingStep step) {
    setState(() {
      _currentStep = step;
      debugPrint('📍 [Onboarding] Navigated to step: ${step.name}');
    });
  }

  Future<void> _handleLogoUpload() async {
    debugPrint('📤 [Onboarding] Opening Logo Upload Screen');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogoUploadScreen(
          onSaveContinue: () => Navigator.pop(context, true),
        ),
      ),
    );

    if (result == true && mounted) {
      _markStepCompleted(OnboardingStep.logoUpload);
      _navigateToStep(OnboardingStep.headshotUpload);
    }
  }

  Future<void> _handleHeadshotUpload() async {
    debugPrint('📤 [Onboarding] Opening Headshot Upload Screen');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPhotosScreen()),
    );

    if (result == true && mounted) {
      _markStepCompleted(OnboardingStep.headshotUpload);
      _navigateToStep(OnboardingStep.companyInfo);
    }
  }

  Future<void> _handleCompanyInfo() async {
    debugPrint('📝 [Onboarding] Opening Company Info Screen');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyInfoScreen(
          onSaveContinue: () => Navigator.pop(context, true),
        ),
      ),
    );

    if (result == true && mounted) {
      _markStepCompleted(OnboardingStep.companyInfo);
      _navigateToStep(OnboardingStep.voiceSample);
    }
  }

  Future<void> _handleVoiceSample() async {
    debugPrint('🎤 [Onboarding] Opening Voice Sample Screen');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecordScriptScreen()),
    );

    if (result == true && mounted) {
      _markStepCompleted(OnboardingStep.voiceSample);
      _navigateToStep(OnboardingStep.writingSample);
    }
  }

  Future<void> _handleWritingSample() async {
    debugPrint('📄 [Onboarding] Opening Writing Sample Screen');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrandVoiceSetupScreen(
          onComplete: () => Navigator.pop(context, true),
        ),
      ),
    );

    if (result == true && mounted) {
      _markStepCompleted(OnboardingStep.writingSample);
      _navigateToStep(OnboardingStep.photosUpload);
    }
  }

  Future<void> _handlePhotosUpload() async {
    debugPrint('📸 [Onboarding] Opening Photos Upload Screen');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPhotosScreen()),
    );

    if (result == true && mounted) {
      _markStepCompleted(OnboardingStep.photosUpload);
      await _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    debugPrint('🎉 [Onboarding] All steps completed! Marking onboarding as complete.');
    await OnboardingService.completeOnboarding();
    
    if (mounted) {
      debugPrint('🎉 [Onboarding] Navigating to Wallet Dashboard');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WalletDashboard()),
      );
    }
  }

  Widget _buildStepCard({
    required OnboardingStep step,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool isCompleted = false,
    bool isLocked = false,
  }) {
    return Card(
      color: isCompleted 
          ? AppColors.buttonGold.withOpacity(0.1)
          : isLocked 
              ? Colors.grey.withOpacity(0.1)
              : AppColors.cardBackground,
      child: ListTile(
        enabled: !isLocked,
        leading: CircleAvatar(
          backgroundColor: isCompleted
              ? AppColors.buttonGold
              : isLocked
                  ? Colors.grey
                  : AppColors.textMuted,
          child: Icon(
            icon,
            color: isCompleted || isLocked
                ? Colors.white
                : AppColors.background,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isCompleted
                ? AppColors.buttonGold
                : isLocked
                    ? Colors.grey
                    : AppColors.textPrimary,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: isCompleted
                ? AppColors.textSecondary
                : isLocked
                    ? Colors.grey
                    : AppColors.textSecondary,
          ),
        ),
        trailing: isCompleted
            ? const Icon(Icons.check_circle, color: AppColors.buttonGold)
            : isLocked
                ? const Icon(Icons.lock, color: Colors.grey)
                : const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 16),
        onTap: isLocked ? null : onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Onboarding Progress',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: TextStyle(
                        color: AppColors.buttonGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AppColors.textMuted,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonGold),
                ),
              ],
            ),
          ),
          
          // Steps List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStepCard(
                  step: OnboardingStep.logoUpload,
                  title: 'Logo Upload',
                  description: 'Upload your company logo',
                  icon: Icons.business,
                  onTap: _handleLogoUpload,
                  isCompleted: _isStepCompleted(OnboardingStep.logoUpload),
                ),
                const SizedBox(height: 8),
                _buildStepCard(
                  step: OnboardingStep.headshotUpload,
                  title: 'Headshot Upload',
                  description: 'Add your professional photos',
                  icon: Icons.person,
                  onTap: _handleHeadshotUpload,
                  isCompleted: _isStepCompleted(OnboardingStep.headshotUpload),
                  isLocked: !_isStepCompleted(OnboardingStep.logoUpload),
                ),
                const SizedBox(height: 8),
                _buildStepCard(
                  step: OnboardingStep.companyInfo,
                  title: 'Company Information',
                  description: 'Add company name and description',
                  icon: Icons.info,
                  onTap: _handleCompanyInfo,
                  isCompleted: _isStepCompleted(OnboardingStep.companyInfo),
                  isLocked: !_isStepCompleted(OnboardingStep.headshotUpload),
                ),
                const SizedBox(height: 8),
                _buildStepCard(
                  step: OnboardingStep.voiceSample,
                  title: 'Voice Sample',
                  description: 'Record your voice sample (MP3)',
                  icon: Icons.mic,
                  onTap: _handleVoiceSample,
                  isCompleted: _isStepCompleted(OnboardingStep.voiceSample),
                  isLocked: !_isStepCompleted(OnboardingStep.companyInfo),
                ),
                const SizedBox(height: 8),
                _buildStepCard(
                  step: OnboardingStep.writingSample,
                  title: 'Writing Sample',
                  description: 'Upload your writing samples',
                  icon: Icons.description,
                  onTap: _handleWritingSample,
                  isCompleted: _isStepCompleted(OnboardingStep.writingSample),
                  isLocked: !_isStepCompleted(OnboardingStep.voiceSample),
                ),
                const SizedBox(height: 8),
                _buildStepCard(
                  step: OnboardingStep.photosUpload,
                  title: 'Photos Upload',
                  description: 'Upload additional photos',
                  icon: Icons.photo_library,
                  onTap: _handlePhotosUpload,
                  isCompleted: _isStepCompleted(OnboardingStep.photosUpload),
                  isLocked: !_isStepCompleted(OnboardingStep.writingSample),
                ),
              ],
            ),
          ),
          
          // Complete Button (only show when all steps are completed)
          if (_completedSteps.length == OnboardingStep.values.length)
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Complete Onboarding',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
