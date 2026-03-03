import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class EmbeddedCheckoutScreen extends StatelessWidget {
  const EmbeddedCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Complete Checkout',
      activeIndex: 3, // Wallet
      child: const _EmbeddedCheckoutLayout(),
    );
  }
}

class _EmbeddedCheckoutLayout extends StatelessWidget {
  const _EmbeddedCheckoutLayout();

  @override
  Widget build(BuildContext context) {
    const divider = Color(0xFF3E3144); // Project border soft
    const accentRose = Color(0xFFCE9799);

    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 980,
          child: Column(
            children: [
              const SizedBox(height: 56),
              const Text(
                'Complete Checkout',
                style: TextStyle(
                  color: accentRose,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              const Divider(color: divider),
              const SizedBox(height: 44),
              const SizedBox(width: 720, child: _CheckoutCard()),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard();

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF1E1E1E);
    const border = Color(0xFF3E3144);
    const accentRose = Color(0xFFCE9799);
    const muted = Color(0xFF9EA3AE);

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Card Number',
            style: TextStyle(
              color: accentRose,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16),
          _FieldGroup(),
          SizedBox(height: 18),
          _PrimaryButton(label: 'Pay & Activate'),
          SizedBox(height: 12),
          Center(
            child: Text(
              'You can cancel anytime.\nYour card details are never stored.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 11, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldGroup extends StatelessWidget {
  const _FieldGroup();

  @override
  Widget build(BuildContext context) {
    const inputBg = Color(0xFF141414);
    const border = Color(0xFF3E3144);

    return Container(
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        children: const [
          _FieldRow(
            icon: Icons.credit_card,
            hint: 'Card Number',
            showDivider: true,
          ),
          _FieldRow(
            icon: Icons.schedule,
            hint: 'MM / YY',
            trailing: _RightStub(),
            showDivider: true,
          ),
          _FieldRow(
            icon: Icons.location_on_outlined,
            hint: 'ZIP Code',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool showDivider;
  final Widget? trailing;

  const _FieldRow({
    required this.icon,
    required this.hint,
    required this.showDivider,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF9EA3AE);
    const border = Color(0xFF3E3144);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 18, color: muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hint,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          if (showDivider) const Divider(height: 1, color: border),
        ],
      ),
    );
  }
}

class _RightStub extends StatelessWidget {
  const _RightStub();

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
          Text('+1', style: TextStyle(color: muted, fontSize: 12)),
          SizedBox(width: 6),
          Icon(Icons.expand_more, size: 16, color: muted),
          SizedBox(width: 10),
          Text('CVC', style: TextStyle(color: muted, fontSize: 12)),
          SizedBox(width: 8),
          _MiniBox(),
          SizedBox(width: 6),
          _MiniBox(),
        ],
      ),
    );
  }
}

class _MiniBox extends StatelessWidget {
  const _MiniBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white12),
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
