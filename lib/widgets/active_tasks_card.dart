// active_tasks_card.dart
import 'package:flutter/material.dart';

class ActiveTasksCard extends StatelessWidget {
  final int totalTasks;
  final int totalValue;
  final int inProgressTasks;
  final int inProgressValue;
  final int awaitingApprovalTasks;
  final int awaitingApprovalValue;

  const ActiveTasksCard({
    Key? key,
    required this.totalTasks,
    required this.totalValue,
    required this.inProgressTasks,
    required this.inProgressValue,
    required this.awaitingApprovalTasks,
    required this.awaitingApprovalValue,
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
            'Active Tasks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          _buildTaskRow('Total', totalTasks, totalValue, null),
          const SizedBox(height: 16),
          _buildTaskRow(
            'In Progress',
            inProgressTasks,
            inProgressValue,
            const Color(0xFFB8764E),
          ),
          const SizedBox(height: 16),
          _buildTaskRow(
            'Awaiting Approval',
            awaitingApprovalTasks,
            awaitingApprovalValue,
            Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskRow(String label, int count, int value, Color? iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 24),
            if (iconColor != null) ...[
              Container(
                width: 32,
                height: 20,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
