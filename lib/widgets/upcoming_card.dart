import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class UpcomingItem {
  final String iconLabel;
  final Color iconColor;
  final String title;
  final String time;
  final String statusLabel;

  const UpcomingItem({
    required this.iconLabel,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.statusLabel,
  });
}

class UpcomingCard extends StatelessWidget {
  const UpcomingCard({super.key, required this.item});

  final UpcomingItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppStyles.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppStyles.borderSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: item.iconColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Icon(Icons.bolt, size: 18, color: item.iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.time,
                  style: const TextStyle(
                    color: AppStyles.mutedText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
