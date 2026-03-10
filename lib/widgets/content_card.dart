import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class ContentCard extends StatelessWidget {
  final String title;
  final String platform;
  final String imageUrl; // asset path OR public URL
  final bool isNetworkImage;
  final String status;
  final int tokens;
  final VoidCallback onApprove; // <--- WIRE YOUR RPC HERE LATER
  final VoidCallback onUploadImage;

  const ContentCard({
    required this.title,
    required this.platform,
    required this.imageUrl,
    this.isNetworkImage = false,
    required this.status,
    required this.tokens,
    required this.onApprove,
    required this.onUploadImage,
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _CardImage(
                      imageUrl: imageUrl,
                      isNetwork: isNetworkImage,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: onUploadImage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.upload_rounded,
                              size: 14,
                              color: Color(0xFFCE9799),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Upload',
                              style: TextStyle(
                                color: Color(0xFFEBE3DE),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

class _CardImage extends StatelessWidget {
  final String imageUrl;
  final bool isNetwork;
  const _CardImage({required this.imageUrl, required this.isNetwork});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const Center(child: Icon(Icons.image, color: Colors.white10));
    }

    if (isNetwork) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('[ContentCard] image failed: $imageUrl');
          return const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.white24),
          );
        },
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('[ContentCard] asset failed: $imageUrl');
        return const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.white24),
        );
      },
    );
  }
}