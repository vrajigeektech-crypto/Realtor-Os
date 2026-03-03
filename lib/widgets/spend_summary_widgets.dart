import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../models/agent_spending_models.dart';

class AgentProfileHeader extends StatelessWidget {
  const AgentProfileHeader({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    if (!isMobile) {
      return Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppStyles.borderSoft),
            ),
            child: const Icon(
              Icons.person,
              color: AppStyles.mutedText,
              size: 36,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Julia Myers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Agent  |  Summit Realty Group',
                  style: TextStyle(color: AppStyles.mutedText, fontSize: 12.5),
                ),
              ],
            ),
          ),
          _StatusBadge(),
          const SizedBox(width: 12),
          _ViewDropdown(),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppStyles.borderSoft),
              ),
              child: const Icon(
                Icons.person,
                color: AppStyles.mutedText,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Julia Myers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Summit Realty Group',
                    style: TextStyle(color: AppStyles.mutedText, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [_StatusBadge(), _ViewDropdown()],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppStyles.statusGreen.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppStyles.statusGreen),
      ),
      child: Row(
        children: const [
          Icon(Icons.circle, size: 8, color: AppStyles.statusGreen),
          SizedBox(width: 6),
          Text(
            'Active',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewDropdown extends StatelessWidget {
  const _ViewDropdown();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppStyles.borderSoft),
      ),
      child: Row(
        children: const [
          Text(
            'Admin View',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, color: AppStyles.mutedText, size: 16),
        ],
      ),
    );
  }
}

class SpendStatCard extends StatelessWidget {
  final String label;
  final String value;
  const SpendStatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 96,
        margin: const EdgeInsets.symmetric(horizontal: 2), // Tighter margin
        decoration: BoxDecoration(
          color: AppStyles.cardColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppStyles.borderSoft),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppStyles.mutedText,
                fontSize: 11.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppStyles.accentRose.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpendBreakdownCard extends StatelessWidget {
  final List<SpendCategory> categories;
  
  const SpendBreakdownCard({super.key, this.categories = const []});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppStyles.cardColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppStyles.borderSoft),
        ),
        child: const Center(
          child: Text(
            'No spend data available',
            style: TextStyle(color: AppStyles.mutedText, fontSize: 12),
          ),
        ),
      );
    }

    final maxAmount = categories
        .map((c) => c.totalAmount)
        .fold(0, (a, b) => a > b ? a : b)
        .toDouble();

    Widget barRow(String label, double fraction, String amount) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 9,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppStyles.borderSoft),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: fraction > 0 ? fraction : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF858E99), Color(0xFFE5E8EC)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            SizedBox(
              width: 100,
              child: Text(
                amount,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppStyles.cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppStyles.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SPEND BREAKDOWN BY CATEGORY',
                style: TextStyle(
                  color: AppStyles.mutedText,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              DropdownButton<String>(
                value: 'This Month',
                dropdownColor: AppStyles.cardColor,
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppStyles.mutedText,
                ),
                items: ['This Month', 'Last Month', 'YTD']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {},
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...categories.map((category) => barRow(
            category.categoryName,
            category.getFraction(maxAmount),
            category.formattedAmount,
          )),
        ],
      ),
    );
  }
}
