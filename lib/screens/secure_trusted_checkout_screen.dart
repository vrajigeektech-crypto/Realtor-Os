import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class SecureTrustedCheckoutScreen extends StatelessWidget {
  const SecureTrustedCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Secure Checkout',
      activeIndex: 3, // Wallet
      child: const _SecureCheckoutLayout(),
    );
  }
}

class _SecureCheckoutLayout extends StatelessWidget {
  const _SecureCheckoutLayout();

  @override
  Widget build(BuildContext context) {
    const divider = Color(0xFF3E3144);
    const accentRose = Color(0xFFCE9799);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const Text(
                'Secure & Trusted Checkout',
                style: TextStyle(
                  color: accentRose,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              const Divider(color: divider),
              const SizedBox(height: 36),
              // Use Column for layout, Row for desktop if needed
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(child: _PaymentCard()),
                        SizedBox(width: 28),
                        SizedBox(width: 360, child: _SummaryCard()),
                      ],
                    );
                  } else {
                    return Column(
                      children: const [
                        _PaymentCard(),
                        SizedBox(height: 28),
                        _SummaryCard(),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              const _TrustFooter(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF1E1E1E);
    const border = Color(0xFF3E3144);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard();

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF9EA3AE);
    const accentRose = Color(0xFFCE9799);
    const innerBg = Color(0xFF141414);
    const border = Color(0xFF3E3144);

    return _CardShell(
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
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: innerBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Column(
              children: const [
                _ValidatedRow(icon: Icons.credit_card, label: 'Card'),
                _DividerLine(),
                _ValidatedRow(
                  icon: Icons.schedule,
                  label: 'MM / YY',
                  trailing: _CvcStub(),
                ),
                _DividerLine(),
                _ValidatedRow(
                  icon: Icons.location_on_outlined,
                  label: 'ZIP Code',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _PrimaryButton(label: 'Pay \$49.00'),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'This purchase activates immediately.',
              style: TextStyle(color: muted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidatedRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;

  const _ValidatedRow({required this.icon, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF9EA3AE);
    const success = Color(0xFF35C86B);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) trailing!,
          const SizedBox(width: 10),
          const Icon(Icons.check_circle, size: 16, color: success),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFF3E3144));
  }
}

class _CvcStub extends StatelessWidget {
  const _CvcStub();

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF9EA3AE);

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.flag_outlined, size: 14, color: muted),
          SizedBox(width: 6),
          Text('CVC', style: TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  const _PrimaryButton({required this.label});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFCE9799);

    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {},
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    const accentRose = Color(0xFFCE9799);
    const border = Color(0xFF3E3144);

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Realtor OS Subscription',
            style: TextStyle(
              color: accentRose,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 14),
          _SummaryRow(label: '\$49.00', value: '\$49.00'),
          SizedBox(height: 14),
          Divider(color: border),
          SizedBox(height: 12),
          _SummaryRow(label: 'Total', value: '\$49.00', isBold: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.white : const Color(0xFF9EA3AE),
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? Colors.white : const Color(0xFF9EA3AE),
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
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
        Icon(Icons.lock_outline, size: 14, color: muted),
        SizedBox(width: 6),
        Text('PCI-compliant', style: TextStyle(color: muted, fontSize: 11)),
        SizedBox(width: 18),
        Icon(Icons.verified_user_outlined, size: 14, color: muted),
        SizedBox(width: 6),
        Text(
          'Used by professionals',
          style: TextStyle(color: muted, fontSize: 11),
        ),
        SizedBox(width: 18),
        Text('stripe', style: TextStyle(color: muted, fontSize: 11)),
      ],
    );
  }
}
