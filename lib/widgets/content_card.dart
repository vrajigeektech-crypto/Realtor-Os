import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class ContentCard extends StatelessWidget {
  final String title;
  final String platform;
  final String imageUrl;
  final String status;
  final int tokens;
  final VoidCallback onApprove; // <--- WIRE YOUR RPC HERE LATER

  const ContentCard({
    required this.title,
    required this.platform,
    required this.imageUrl,
    required this.status,
    required this.tokens,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 234, // Matches your Figma Group measurement
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Platform Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(Icons.play_circle_fill, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text(platform, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Image placeholder (VA can replace with Image.asset)
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.surfaceHigh,
              child: Center(child: Icon(Icons.image, color: Colors.white10)),
            ),
          ),
          // Content Info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: TextStyle(color: Colors.orange, fontSize: 10)),
                SizedBox(height: 4),
                Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(height: 12),
                InkWell(
                  onTap: onApprove,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.buttonGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text("Approve & Post", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ),
                ),
                SizedBox(height: 8),
                Center(child: Text("🪙 $tokens tokens", style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}