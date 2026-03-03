import 'package:flutter/material.dart';

enum IntegrationStatus { connected, disconnected }

class IntegrationCard extends StatelessWidget {
  final String name;
  final IntegrationStatus status;

  const IntegrationCard({
    super.key,
    required this.name,
    required this.status,
  });

  bool get isConnected => status == IntegrationStatus.connected;

  String? _getImagePath() {
    switch (name.toLowerCase()) {
      case 'salesforce':
        return 'assets/salesforce_logo.png';
      case 'hubspot':
        return 'assets/hubspot_logo.png';
      case 'facebook':
        return 'assets/facebook_logo.png';
      case 'instagram':
        return 'assets/instagram_logo.png';
      case 'linkedin':
        return 'assets/linkedin_logo.png';
      case 'stripe':
        return 'assets/stripe_logo.png';
      case 'paypal':
        return 'assets/paypal_logo.png';
      case 'calendly':
        return 'assets/calendly_logo.png';
      case 'trello':
        return 'assets/trello_logo.png';
      case 'zapier':
        return 'assets/zapier_logo.png';
      case 'google drive':
        return 'assets/google_drive_logo.png';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imagePath = _getImagePath();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected ? Colors.greenAccent.withOpacity(0.5) : Colors.grey.shade700,
          width: isConnected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              if (imagePath != null)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Image.asset(
                      imagePath,
                      width: 32,
                      height: 32,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.business,
                          size: 32,
                          color: Colors.grey.shade400,
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.business,
                      size: 32,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Column(
            children: [
              if (isConnected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 14),
                      const SizedBox(width: 6),
                      const Text(
                        'Connected',
                        style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade500],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Connect',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
