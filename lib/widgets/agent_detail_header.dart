import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class AgentDetailHeader extends StatelessWidget {
  const AgentDetailHeader({
    super.key,
    required this.activeIndex,
    required this.onTabTap,
    required this.title,
  });

  final int activeIndex;
  final ValueChanged<int> onTabTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      'Profile',
      'Spend',
      'Usage',
      'Tasks & Queue',
      'Integrations',
      'Assets',
      'Onboarding',
      'Security',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        color: AppStyles.darkBackground,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isActive = index == activeIndex;
                return InkWell(
                  onTap: () => onTabTap(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isActive
                              ? AppStyles.accentRose
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: isActive ? Colors.white : AppStyles.mutedText,
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
