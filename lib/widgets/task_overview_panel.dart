import 'package:flutter/material.dart';
import '../models/task_overview.dart';

class TaskOverviewPanel extends StatelessWidget {
  final TaskOverview overview;

  const TaskOverviewPanel({
    super.key,
    required this.overview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatRow(
            'Total Open Tasks',
            overview.totalOpenTasks.toString(),
            isHighlighted: false,
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Awaiting Approval',
            overview.awaitingApproval.toString(),
            isHighlighted: false,
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'SLA Breaches Today',
            overview.slaBreachesToday.toString(),
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlighted ? const Color(0xFFFF6B35) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
