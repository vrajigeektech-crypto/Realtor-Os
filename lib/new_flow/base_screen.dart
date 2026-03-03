import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Base class for all new flow screens with consistent styling and behavior
abstract class NewFlowBaseScreen extends StatefulWidget {
  const NewFlowBaseScreen({super.key});

  /// Screen title for the app bar
  String get screenTitle;

  /// Whether to show back button
  bool get showBackButton => true;

  /// Whether to show skip button
  bool get showSkipButton => false;

  /// Progress value (0.0 to 1.0)
  double get progress;

  /// Build the main content of the screen
  Widget buildContent(BuildContext context);

  /// Handle next button press
  Future<void> onNext(BuildContext context) async {}

  /// Handle skip button press
  Future<void> onSkip(BuildContext context) async {}

  /// Handle back button press
  Future<bool> onBackPressed() async {
    return true;
  }

  @override
  State<NewFlowBaseScreen> createState() => _NewFlowBaseScreenState();
}

class _NewFlowBaseScreenState extends State<NewFlowBaseScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: widget.onBackPressed,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: widget.buildContent(context),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.screenTitle,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () async {
                if (await widget.onBackPressed()) {
                  Navigator.of(context).pop();
                }
              },
            )
          : null,
      actions: widget.showSkipButton
          ? [
              TextButton(
                onPressed: _isLoading ? null : () => widget.onSkip(context),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ]
          : null,
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: widget.progress,
            backgroundColor: AppColors.surfaceHigh,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.buttonGold),
            minHeight: 4,
          ),
          const SizedBox(height: 8),
          Text(
            '${(widget.progress * 100).toInt()}% Complete',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
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
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _handleNext(),
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
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleNext() async {
    setState(() => _isLoading = true);
    try {
      await widget.onNext(context);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
