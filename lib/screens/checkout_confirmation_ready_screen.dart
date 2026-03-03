import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../layout/main_layout.dart';
import '../utils/app_styles.dart';

class CheckoutConfirmationReadyScreen extends StatelessWidget {
  const CheckoutConfirmationReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Checkout Confirmation',
      activeIndex: 3,
      child: const _CheckoutConfirmationLayout(),
    );
  }
}

class _CheckoutConfirmationLayout extends StatelessWidget {
  const _CheckoutConfirmationLayout();

  @override
  Widget build(BuildContext context) {
    const divider = Color(0xFF3E3144);
    const accentRose = Color(0xFFCE9799);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Complete Checkout',
                style: TextStyle(
                  color: accentRose, // Used Accent
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 18),
              const Divider(color: divider)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 44),
              const _ConfirmationCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: 26),
              const _TrustFooter()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmationCard extends StatelessWidget {
  const _ConfirmationCard();

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF9EA3AE);
    const accentRose = Color(0xFFCE9799);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppStyles.glassPanelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Number',
            style: TextStyle(
              color: accentRose,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const _ReadyFieldGroup(),
          const SizedBox(height: 24),
          const _PrimaryButton(label: 'Submit Payment'),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'This purchase activates immediately.',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyFieldGroup extends StatelessWidget {
  const _ReadyFieldGroup();

  @override
  Widget build(BuildContext context) {
    const innerBg = Color(0xFF141414);
    const border = Color(0xFF3E3144);

    return Container(
      decoration: BoxDecoration(
        color: innerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          _ReadyRow(
            leftText: '4242 4242 4242 4242',
            rightBadge: _VisaBadge(),
            showDivider: true,
          ),
          _ReadyRow(leftText: '12 / 28', showDivider: true),
          _ReadyRow(leftWidget: _ZipWithFlag(), showDivider: false),
        ],
      ),
    );
  }
}

class _ReadyRow extends StatelessWidget {
  final String? leftText;
  final Widget? leftWidget;
  final bool showDivider;
  final Widget? rightBadge;

  const _ReadyRow({
    this.leftText,
    this.leftWidget,
    required this.showDivider,
    this.rightBadge,
  });

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;
    const success = Color(0xFF35C86B);
    const border = Color(0xFF3E3144);

    return SizedBox(
      height: 60,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: leftWidget ??
                        Text(
                          leftText ?? '',
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                  ),
                  if (rightBadge != null) ...[
                    rightBadge!,
                    const SizedBox(width: 12),
                  ],
                  const Icon(Icons.check_circle, size: 20, color: success)
                      .animate()
                      .scale(
                        duration: 300.ms,
                        curve: Curves.easeOutBack,
                        delay: 600.ms,
                      ),
                ],
              ),
            ),
          ),
          if (showDivider) const Divider(height: 1, color: border),
        ],
      ),
    );
  }
}

class _VisaBadge extends StatelessWidget {
  const _VisaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      alignment: Alignment.center,
      child: const Text(
        'VISA',
        style: TextStyle(
          color: AppStyles.mutedText,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ZipWithFlag extends StatelessWidget {
  const _ZipWithFlag();

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;

    return Row(
      children: const [
        Icon(Icons.flag_outlined, size: 18, color: AppStyles.mutedText),
        SizedBox(width: 12),
        Text(
          '90210',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;

  const _PrimaryButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return AppAnimations.scaleButton(
      onTap: () {
        AppAnimations.showFeedback(context, "Payment Processed successfully!");
      },
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppStyles.copperGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppStyles.accentRose.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _TrustFooter extends StatelessWidget {
  const _TrustFooter();

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF9EA3AE);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.lock_outline, size: 16, color: muted),
        SizedBox(width: 6),
        Text('Secure Payment', style: TextStyle(color: muted, fontSize: 13)),
        SizedBox(width: 24),
        Icon(Icons.verified_user_outlined, size: 16, color: muted),
        SizedBox(width: 6),
        Text('Trusted Service', style: TextStyle(color: muted, fontSize: 13)),
        SizedBox(width: 24),
        Text(
          'stripe',
          style: TextStyle(
            color: muted,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// Simple AppAnimations mock for standalone use if app_styles isn't updated
class AppAnimations {
  static Widget scaleButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: child, // In a real app, wrap with a scaling stateful widget
    );
  }
  static void showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppStyles.accentRose,
        behavior: SnackBarBehavior.floating,
      )
    );
  }
}

extension BoxShadowInset on BoxShadow {
  // Mock extension for 'inset: true' if not supported explicitly in native BoxShadow
  // In Flutter, inset shadows require custom painting or stacked containers.
  // We use standard outsets in actual code.
}
