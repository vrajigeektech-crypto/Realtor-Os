// agent_milestones_card.dart
import 'package:flutter/material.dart';

class AgentMilestonesCard extends StatelessWidget {
  final int currentXp;
  final int nextLevelXp;
  final double tokensEarned;
  final String lastLnutDays;

  final int nextMilestoneAmount;
  final int nextMilestoneDays;
  final bool cardSetupComplete;
  final String cardLastFour;

  const AgentMilestonesCard({
    Key? key,
    required this.currentXp,
    required this.nextLevelXp,
    required this.tokensEarned,
    required this.lastLnutDays,
    required this.nextMilestoneAmount,
    required this.nextMilestoneDays,
    required this.cardSetupComplete,
    required this.cardLastFour,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress =
        nextLevelXp == 0 ? 0.0 : (currentXp / nextLevelXp).clamp(0.0, 1.0);

    return Column(
      children: [
        // XP + Progress Card
        Container(
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
                'Agent Milestones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$currentXp',
                    style: const TextStyle(
                      color: Color(0xFFB8764E),
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'XP',
                      style: TextStyle(
                        color: const Color(0xFFB8764E).withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next Level: $nextLevelXp XP',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const Icon(
                    Icons.workspace_premium,
                    color: Color(0xFFB8764E),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFB8764E),
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tokens Earned: ${tokensEarned.toStringAsFixed(0)} OST',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white54, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'Last spend: $lastLnutDays',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1810),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.access_time, color: Colors.white54, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Last Spend',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Next Milestone + Card Info
        Container(
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
                'Next Milestone',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB8764E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$nextMilestoneAmount OST',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'in $nextMilestoneDays days',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card,
                        color: Colors.white54, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Card setup complete',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                cardSetupComplete
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: cardSetupComplete
                                    ? Colors.green
                                    : Colors.red,
                                size: 14,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '•••• $cardLastFour',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
