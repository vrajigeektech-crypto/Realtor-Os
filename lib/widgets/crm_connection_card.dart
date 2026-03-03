
// lib/widgets/crm_connection_card.dart
import 'package:flutter/material.dart';

class CrmConnectionCard extends StatelessWidget {
  final String name;
  final String logoPath;
  final bool isConnected;
  final bool isLoading;
  final VoidCallback onTap;

  const CrmConnectionCard({
    Key? key,
    required this.name,
    required this.logoPath,
    required this.isConnected,
    this.isLoading = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4a574)),
                ),
              )
            else if (isConnected)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Connected',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4a5568)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Connect',
                  style: TextStyle(color: Color(0xFF9ca3af), fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

