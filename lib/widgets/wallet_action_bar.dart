// wallet_action_bar.dart
import 'package:flutter/material.dart';

class WalletActionBar extends StatelessWidget {
  final VoidCallback? onAdjustBalance;
  final VoidCallback? onRecallTokens;
  final VoidCallback? onSetWalletCap;
  final VoidCallback? onFreeze;

  const WalletActionBar({
    Key? key,
    this.onAdjustBalance,
    this.onRecallTokens,
    this.onSetWalletCap,
    this.onFreeze,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildActionButton('Adjust Balance', false, onAdjustBalance),
          const SizedBox(width: 12),
          _buildActionButton('Recall Tokens', false, onRecallTokens),
          const SizedBox(width: 12),
          _buildActionButton('Recall Tokens', false, onRecallTokens),
          const SizedBox(width: 12),
          _buildActionButton('Set Wallet Cap', false, onSetWalletCap),
          const SizedBox(width: 12),
          _buildActionButton('Freeze', true, onFreeze),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    bool hasDropdown,
    VoidCallback? onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(4),
          color: hasDropdown ? const Color(0xFF2A1810) : Colors.transparent,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
