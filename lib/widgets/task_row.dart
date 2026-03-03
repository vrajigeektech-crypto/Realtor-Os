import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_priority.dart';
import '../models/task_status.dart';

class TaskRow extends StatelessWidget {
  final Task task;
  final VoidCallback? onViewDetails;

  const TaskRow({
    super.key,
    required this.task,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    if (isMobile) {
      return _buildMobileRow(context);
    } else {
      return _buildDesktopRow(context);
    }
  }

  Widget _buildDesktopRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Task ID
          SizedBox(
            width: 80,
            child: Text(
              task.id.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          // Task Type
          Expanded(
            flex: 2,
            child: Text(
              task.taskType,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          // Status
          Expanded(
            flex: 2,
            child: Text(
              task.status.displayName,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          // Priority
          Expanded(
            flex: 2,
            child: Text(
              task.priority.displayName,
              style: TextStyle(
                color: task.priority.isHighlighted
                    ? const Color(0xFFFF6B35)
                    : Colors.white,
                fontSize: 14,
                fontWeight: task.priority.isHighlighted
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          // SLA Countdown
          Expanded(
            flex: 2,
            child: Text(
              task.slaCountdown,
              style: TextStyle(
                color: task.slaCountdown.contains('overdue')
                    ? const Color(0xFFFF6B35)
                    : Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          // Queue Position
          SizedBox(
            width: 100,
            child: Text(
              task.queuePosition.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          // Assigned Admin
          Expanded(
            flex: 2,
            child: Text(
              task.assignedAdmin,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          // Actions
          SizedBox(
            width: 140,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'View Task Detail',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileRow(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Task #${task.id}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: task.status == TaskStatus.completed
                      ? Colors.green.withOpacity(0.2)
                      : task.status == TaskStatus.inProgress
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.status.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMobileInfoRow('Type', task.taskType),
          _buildMobileInfoRow('Priority', task.priority.displayName,
              isHighlighted: task.priority.isHighlighted),
          _buildMobileInfoRow('SLA', task.slaCountdown,
              isOverdue: task.slaCountdown.contains('overdue')),
          _buildMobileInfoRow('Queue Position', task.queuePosition.toString()),
          _buildMobileInfoRow('Assigned To', task.assignedAdmin),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('View Task Detail'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileInfoRow(String label, String value,
      {bool isHighlighted = false, bool isOverdue = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isOverdue
                  ? const Color(0xFFFF6B35)
                  : isHighlighted
                      ? const Color(0xFFFF6B35)
                      : Colors.white,
              fontSize: 12,
              fontWeight: isHighlighted || isOverdue
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
