import 'package:flutter/material.dart';
import '../widgets/brand_voice_header.widget.dart';
import '../widgets/onboarding_progress_bar.widget.dart';
import '../widgets/brand_asset_card.widget.dart';
import '../widgets/voice_sample_card.widget.dart';
import '../widgets/writing_sample_card.widget.dart';

import 'add_photos_screen.dart';
import 'agent_wallet_screen.dart';
import 'logo_upload_screen.dart';
import 'record_script_screen.dart';
import '../widgets/writing_samples_screen.widget.dart';

enum OnboardingStepState { locked, active, completed }

class BrandVoiceSetupScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const BrandVoiceSetupScreen({super.key, this.onComplete});

  @override
  State<BrandVoiceSetupScreen> createState() => _BrandVoiceSetupScreenState();
}

class _BrandVoiceSetupScreenState extends State<BrandVoiceSetupScreen> {
  OnboardingStepState _logoStep = OnboardingStepState.active;
  OnboardingStepState _headshotStep = OnboardingStepState.active;
  OnboardingStepState _voiceStep = OnboardingStepState.locked;
  OnboardingStepState _writingStep = OnboardingStepState.locked;

  int get _completedCount => [
    _logoStep,
    _headshotStep,
    _voiceStep,
    _writingStep,
  ].where((s) => s == OnboardingStepState.completed).length;

  double get _progress => _completedCount / 4.0;

  void _markStepCompleted(OnboardingStepState step) {
    setState(() {
      if (step == _logoStep) {
        _logoStep = OnboardingStepState.completed;
        _headshotStep = OnboardingStepState.active;
      } else if (step == _headshotStep) {
        _headshotStep = OnboardingStepState.completed;
        _voiceStep = OnboardingStepState.active;
      } else if (step == _voiceStep) {
        _voiceStep = OnboardingStepState.completed;
        _writingStep = OnboardingStepState.active;
      } else if (step == _writingStep) {
        _writingStep = OnboardingStepState.completed;
      }
    });
  }

  Future<void> _handleLogoUpload() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogoUploadScreen(
          onSaveContinue: () => Navigator.pop(context, true),
        ),
      ),
    );

    if (result == true && mounted) {
      _markStepCompleted(_logoStep);
    }
  }

  Future<void> _handleHeadshotUpload() async {
    debugPrint('🔘 [Headshot] Headshot button tapped');

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPhotosScreen()),
    );

    if (result == true && mounted) {
      _markStepCompleted(_headshotStep);
    }
  }

  Future<void> _handleVoiceRecording() async {
    if (_voiceStep == OnboardingStepState.locked) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecordScriptScreen()),
    );

    if (result == true && mounted) {
      _markStepCompleted(_voiceStep);
    }
  }

  Future<void> _handleWritingSamples() async {
    if (_writingStep == OnboardingStepState.locked) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WritingSamplesScreen(
          onUploadExamples: () => Navigator.pop(context, true),
        ),
      ),
    );

    if (result == true && mounted) {
      _markStepCompleted(_writingStep);
    }
  }

  void _handleContinue() {
    debugPrint('➡️ Navigating from BrandVoiceScreen → AgentWalletScreen');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AgentWalletScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BrandVoiceHeader(currentStep: _completedCount + 1, totalSteps: 4),
            OnboardingProgressBar(progress: _progress),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  BrandAssetCard(
                    title: 'Your Logo',
                    description:
                        'Upload your logo so it appears alongside your content.',
                    ctaLabel: 'Upload Logo',
                    assetLabel: 'Logo',
                    assetUrl: _logoStep == OnboardingStepState.completed
                        ? 'uploaded'
                        : null,
                    onTapCta: _handleLogoUpload,
                  ),
                  const SizedBox(height: 16),
                  BrandAssetCard(
                    title: 'Your Headshot',
                    description: 'Upload photos for your profile gallery.',
                    ctaLabel: 'Add Photos',
                    assetLabel: 'Photos',
                    assetUrl: _headshotStep == OnboardingStepState.completed
                        ? 'uploaded'
                        : null,
                    onTapCta: _handleHeadshotUpload,
                  ),
                  const SizedBox(height: 16),
                  VoiceSampleCard(
                    onRecordPressed: _voiceStep != OnboardingStepState.locked
                        ? () => _handleVoiceRecording()
                        : () {},
                    isEnabled: _voiceStep != OnboardingStepState.locked,
                  ),
                  const SizedBox(height: 16),
                  WritingSampleCard(
                    title: 'Your Writing Samples',
                    description:
                        'Upload past newsletters or emails so we can match your language and tone.',
                    ctaLabel: 'Upload Examples',
                    onCtaPressed: _writingStep != OnboardingStepState.locked
                        ? () => _handleWritingSamples()
                        : () {},
                  ),
                ],
              ),
            ),
            OnboardingFooter(
              onContinue: _handleContinue,
              isContinueEnabled: true,
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    super.key,
    required this.onContinue,
    this.isContinueEnabled = false,
  });

  final VoidCallback onContinue;
  final bool isContinueEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: isContinueEnabled ? onContinue : null,
          child: const Text('Continue'),
        ),
      ),
    );
  }
}
