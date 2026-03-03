import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class TaskHeaderCard extends StatelessWidget {
  const TaskHeaderCard({
    super.key,
    required this.isMobile,
    this.taskId,
    this.agentName,
    this.agentInitials,
    this.brokerageName,
    this.totalTasks,
    this.joinedDate,
  });

  final bool isMobile;
  final String? taskId;
  final String? agentName;
  final String? agentInitials;
  final String? brokerageName;
  final int? totalTasks;
  final String? joinedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppStyles.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppStyles.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade700,
            child: const Text(
              'FM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task ID: #8731',
                  style: TextStyle(color: AppStyles.mutedText, fontSize: 11),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Frank Miller',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Miller Realty',
                  style: TextStyle(color: AppStyles.mutedText, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                const TaskMetaRow(),
              ],
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppStyles.borderSoft),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Task ID: #8731',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppStyles.mutedText,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatTaskId(String taskId) {
  if (taskId.length > 4) {
    return '#${taskId.substring(taskId.length - 4)}';
  }
  return '#$taskId';
}

String? _getInitials(String? name) {
  if (name == null || name.isEmpty) return null;
  final parts = name.trim().split(' ');
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  } else if (parts.length == 1) {
    return parts[0][0].toUpperCase();
  }
  return null;
}

class TaskMetaRow extends StatelessWidget {
  const TaskMetaRow({super.key, this.totalTasks, this.joinedDate});

  final int? totalTasks;
  final String? joinedDate;

  @override
  Widget build(BuildContext context) {
    Text meta(String text) => Text(
      text,
      style: const TextStyle(color: AppStyles.mutedText, fontSize: 11),
      overflow: TextOverflow.ellipsis,
    );

    String tasksText = totalTasks != null ? '$totalTasks Tasks' : 'Tasks';
    String joinedText = joinedDate != null ? 'Joined $joinedDate' : 'Joined';

    return Row(
      children: [
        const Icon(Icons.task_alt, size: 12, color: AppStyles.mutedText),
        const SizedBox(width: 4),
        Flexible(child: meta('$tasksText · $joinedText')),
      ],
    );
  }
}
