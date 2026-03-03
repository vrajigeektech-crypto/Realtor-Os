import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Base widget for all new flow screens with consistent styling and behavior
class NewFlowScreenWrapper extends StatelessWidget {
  final String screenTitle;
  final bool showBackButton;
  final bool showSkipButton;
  final double progress;
  final Widget child;
  final Future<bool> Function()? onBackPressed;
  final VoidCallback? onSkip;
  final VoidCallback? onNext;
  final bool isLoading;
  final String nextButtonText;

  const NewFlowScreenWrapper({
    super.key,
    required this.screenTitle,
    required this.progress,
    required this.child,
    this.showBackButton = true,
    this.showSkipButton = false,
    this.onBackPressed,
    this.onSkip,
    this.onNext,
    this.isLoading = false,
    this.nextButtonText = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: onBackPressed != null ? false : true,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (onBackPressed != null) {
          final canPop = await onBackPressed!();
          if (canPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            _buildProgressBar(),
            Expanded(child: child),
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: onBackPressed != null 
                  ? () async {
                      if (await onBackPressed!()) {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    }
                  : () => Navigator.of(context).pop(),
            )
          : null,
      actions: showSkipButton && onSkip != null
          ? [
              TextButton(
                onPressed: isLoading ? null : onSkip,
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

  Widget _buildBottomActions(BuildContext context) {
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
            onPressed: isLoading || onNext == null ? null : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonGold,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                    ),
                  )
                : Text(
                    nextButtonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
