import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../layout/main_layout.dart';
import '../utils/app_styles.dart';
import '../services/stripe_service.dart';

class CompletePurchaseScreen extends StatelessWidget {
  const CompletePurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Complete Checkout',
      activeIndex: 3,
      child: const _CompletePurchaseLayout(),
    );
  }
}

class _CompletePurchaseLayout extends StatelessWidget {
  const _CompletePurchaseLayout();

  @override
  Widget build(BuildContext context) {
    const divider = Color(0xFF3E3144);
    const accentRose = Color(0xFFCE9799);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Complete Checkout',
                style: TextStyle(
                  color: accentRose,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),
              const Divider(color: divider)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 40),
              const _CheckoutFormCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: 24),
              const _TrustFooterLite()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutFormCard extends StatefulWidget {
  const _CheckoutFormCard();

  @override
  State<_CheckoutFormCard> createState() => _CheckoutFormCardState();
}

class _CheckoutFormCardState extends State<_CheckoutFormCard> {
  bool _isLoading = false;

  Future<void> _handlePayment() async {
    setState(() => _isLoading = true);
    try {
      final stripe = StripeService();
      // Use the provided product ID for activation
      await stripe.processPayment(productId: 'prod_U06aN1WnzDJNRspk');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const _EmptyFieldGroup(),
          const SizedBox(height: 32),
          AppAnimations.scaleButton(
            onTap: _isLoading ? () {} : _handlePayment,
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
              child: _isLoading 
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Pay & Activate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFieldGroup extends StatelessWidget {
  const _EmptyFieldGroup();

  @override
  Widget build(BuildContext context) {
    const innerBg = Color(0xFF141414);
    const border = Color(0xFF3E3144);
    const muted = Color(0xFF9EA3AE);

    return Container(
      decoration: BoxDecoration(
        color: innerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          _EmptyRow(
            icon: Icons.credit_card,
            placeholder: 'Card Number',
            showDivider: true,
          ),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: const [
                        Icon(Icons.calendar_today, size: 18, color: muted),
                        SizedBox(width: 12),
                        Text(
                          'MM / YY',
                          style: TextStyle(color: muted, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, color: border),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: const [
                        Icon(Icons.flag_outlined, size: 18, color: muted),
                        SizedBox(width: 6),
                        Text(
                          '+1',
                          style: TextStyle(color: muted, fontSize: 14),
                        ),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: muted),
                        SizedBox(width: 12),
                        Text(
                          'CVC',
                          style: TextStyle(color: muted, fontSize: 16),
                        ),
                        Spacer(),
                        _CvcBox(),
                        _CvcBox(),
                        _CvcBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: border),
          _EmptyRow(
            icon: Icons.location_on_outlined,
            placeholder: 'ZIP Code',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final IconData icon;
  final String placeholder;
  final bool showDivider;

  const _EmptyRow({
    required this.icon,
    required this.placeholder,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFF3E3144);
    const muted = Color(0xFF9EA3AE);

    return SizedBox(
      height: 60,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: muted),
                  const SizedBox(width: 12),
                  Text(
                    placeholder,
                    style: const TextStyle(color: muted, fontSize: 16),
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

class _CvcBox extends StatelessWidget {
  const _CvcBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _TrustFooterLite extends StatelessWidget {
  const _TrustFooterLite();

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF9EA3AE);

    return Column(
      children: const [
        Text('You can cancel anytime.', style: TextStyle(color: muted, fontSize: 13)),
        SizedBox(height: 6),
        Text(
          'Your card details are never stored.',
          style: TextStyle(color: muted, fontSize: 13),
        ),
      ],
    );
  }
}

// Simple AppAnimations mock for standalone use
class AppAnimations {
  static Widget scaleButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: child, // Minimal implementaion
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
