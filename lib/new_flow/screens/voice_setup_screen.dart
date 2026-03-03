import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../screen_wrapper.dart';

/// Voice setup screen for the new onboarding flow
class NewFlowVoiceSetupScreen extends StatefulWidget {
  const NewFlowVoiceSetupScreen({super.key});

  @override
  State<NewFlowVoiceSetupScreen> createState() => _NewFlowVoiceSetupScreenState();
}

class _NewFlowVoiceSetupScreenState extends State<NewFlowVoiceSetupScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  String get screenTitle => 'Voice Setup';
  double get progress => 0.6;
  bool get showSkipButton => true;

  // State variables
  bool _isRecording = false;
  bool _hasRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  late final AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

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
            'Record your voice sample',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Help our AI sound more like you in video content',
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
                  _buildRecordingSection(),
                  const SizedBox(height: 32),
                  _buildScriptSection(),
                  const SizedBox(height: 32),
                  _buildTipsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentBrown.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Voice waveform visualization
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isRecording 
                ? _buildWaveformAnimation()
                : _buildIdleWaveform(),
          ),
          
          const SizedBox(height: 24),
          
          // Recording controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: _isRecording ? Icons.stop : Icons.mic,
                label: _isRecording ? 'Stop' : 'Record',
                onPressed: _toggleRecording,
                isPrimary: true,
              ),
              
              if (_hasRecording) ...[
                _buildControlButton(
                  icon: Icons.play_arrow,
                  label: 'Play',
                  onPressed: _playRecording,
                ),
                
                _buildControlButton(
                  icon: Icons.refresh,
                  label: 'Re-record',
                  onPressed: _resetRecording,
                ),
              ],
            ],
          ),
          
          if (_isRecording) ...[
            const SizedBox(height: 16),
            Text(
              'Recording... ${_recordingDuration}s',
              style: const TextStyle(
                color: AppColors.buttonGold,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIdleWaveform() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.graphic_eq,
            size: 40,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 8),
          Text(
            'Tap Record to start',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformAnimation() {
    return Center(
      child: AnimatedBuilder(
        animation: _waveformController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(20, (index) {
              final height = 20.0 + (index % 3) * 15.0 * _waveformController.value;
              return Container(
                width: 3,
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.buttonGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.buttonGold : AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(28),
              border: isPrimary 
                  ? null 
                  : Border.all(color: AppColors.accentBrown.withOpacity(0.3)),
            ),
            child: Icon(
              icon,
              color: isPrimary ? AppColors.textPrimary : AppColors.textSecondary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildScriptSection() {
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
          Row(
            children: [
              Icon(Icons.description, color: AppColors.buttonGold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Sample Script',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Hi, I\'m a real estate agent specializing in helping clients find their perfect homes. With years of experience in the local market, I provide personalized service to make your real estate journey smooth and successful.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              TextButton.icon(
                onPressed: _changeScript,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Change Script'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.buttonGold,
                ),
              ),
              const Spacer(),
              Text(
                'Read this in your natural voice',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.buttonGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.buttonGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.buttonGold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Recording Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ...const [
            'Find a quiet environment with minimal background noise',
            'Speak naturally and at a normal pace',
            'Keep your phone 6-12 inches from your mouth',
            'Record for at least 30 seconds for best results',
          ].map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.buttonGold,
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.only(top: 8, right: 12),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _startRecording();
      } else {
        _stopRecording();
      }
    });
  }

  void _startRecording() {
    _waveformController.repeat(reverse: true);
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordingDuration++);
    });
  }

  void _stopRecording() {
    _waveformController.stop();
    _waveformController.reset();
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _hasRecording = true;
      _recordingDuration = 0;
    });
  }

  void _playRecording() {
    // TODO: Implement playback
  }

  void _resetRecording() {
    setState(() {
      _hasRecording = false;
      _recordingDuration = 0;
    });
  }

  void _changeScript() {
    // TODO: Implement script change
  }

  Future<void> _handleNext(BuildContext context) async {
    if (_hasRecording) {
      setState(() => _isLoading = true);
      try {
        // Save voice sample and navigate
        Navigator.of(context).pushNamed('/new_flow/complete');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record a voice sample first')),
      );
    }
  }

  Future<void> _handleSkip(BuildContext context) async {
    Navigator.of(context).pushNamed('/new_flow/complete');
  }

  @override
  void dispose() {
    _waveformController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }
}
