// sla_health_card.dart
import 'package:flutter/material.dart';

class SlaHealthCard extends StatelessWidget {
  final int recentSlaBreaches;
  final int tasksAtRisk;
  final int xpEarned;
  final int nextLv;

  const SlaHealthCard({
    Key? key,
    required this.recentSlaBreaches,
    required this.tasksAtRisk,
    required this.xpEarned,
    required this.nextLv,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SLA Health',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          _buildHealthRow('Recent SLA Breaches', recentSlaBreaches, Colors.red),
          const SizedBox(height: 16),
          _buildHealthRow('Tasks At-Risk', tasksAtRisk, Colors.orange),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFB8764E), size: 20),
              const SizedBox(width: 8),
              const Text(
                'XP Earned',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                'Next LV $nextLv',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRow(String label, int value, Color color) {
    final normalized = value.clamp(0, 3);
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Row(
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: index < normalized ? color : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
