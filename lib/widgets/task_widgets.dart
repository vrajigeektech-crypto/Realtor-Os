import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class TaskRowData {
  final String agentInitials;
  final String agentName;
  final String agentOrg;
  final String agentMeta;
  final String taskType;
  final String? taskTag;
  final String priority;
  final String postTitle;
  final String postSubtitle;
  final String status;
  final String slaShort;
  final String slaFull;

  const TaskRowData({
    required this.agentInitials,
    required this.agentName,
    required this.agentOrg,
    required this.agentMeta,
    required this.taskType,
    this.taskTag,
    required this.priority,
    required this.postTitle,
    required this.postSubtitle,
    required this.status,
    required this.slaShort,
    required this.slaFull,
  });
}

class TaskTableRow extends StatelessWidget {
  const TaskTableRow({super.key, required this.row});

  final TaskRowData row;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: AppStyles.panelColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: _agentAvatarCell(row)),
          const SizedBox(width: 12),
          SizedBox(width: 180, child: _agentInfo(row)),
          const SizedBox(width: 12),
          SizedBox(width: 150, child: _taskTypeCell(row)),
          const SizedBox(width: 12),
          SizedBox(width: 90, child: _priorityCell(row)),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: _postContentCell(row)),
          const SizedBox(width: 12),
          SizedBox(width: 120, child: _statusCell(row)),
          const SizedBox(width: 12),
          SizedBox(width: 120, child: _slaCell(row)),
          const SizedBox(width: 12),
          SizedBox(width: 160, child: _actionsCell(row)),
        ],
      ),
    );
  }

  Widget _agentAvatarCell(TaskRowData row) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade700,
          child: Text(
            row.agentInitials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _agentInfo(TaskRowData row) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row.agentName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          row.agentOrg,
          style: const TextStyle(color: AppStyles.mutedText, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.work_outline,
              size: 12,
              color: AppStyles.mutedText,
            ),
            const SizedBox(width: 4),
            Text(
              row.agentMeta,
              style: const TextStyle(
                color: AppStyles.mutedText,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _taskTypeCell(TaskRowData row) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row.taskType,
          style: const TextStyle(color: Colors.white, fontSize: 12.5),
        ),
        const SizedBox(height: 4),
        if (row.taskTag != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppStyles.borderSoft),
              color: const Color(0xFF22222A),
            ),
            child: Text(
              row.taskTag!,
              style: const TextStyle(
                color: AppStyles.mutedText,
                fontSize: 10.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _priorityCell(TaskRowData row) {
    Color color;
    switch (row.priority) {
      case 'High':
        color = Colors.orangeAccent;
        break;
      case 'Urgent':
        color = Colors.redAccent;
        break;
      default:
        color = Colors.white;
    }

    return Text(
      row.priority,
      style: TextStyle(
        color: color,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _postContentCell(TaskRowData row) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row.postTitle,
          style: const TextStyle(color: Colors.white, fontSize: 12.5),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          row.postSubtitle,
          style: const TextStyle(color: AppStyles.mutedText, fontSize: 11.5),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _statusCell(TaskRowData row) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppStyles.accentRose),
          color: AppStyles.accentRose.withValues(alpha: 0.12),
        ),
        child: Text(
          row.status,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _slaCell(TaskRowData row) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, size: 14, color: Colors.orangeAccent),
            const SizedBox(width: 4),
            Text(
              row.slaShort,
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          row.slaFull,
          style: const TextStyle(color: AppStyles.mutedText, fontSize: 11),
        ),
      ],
    );
  }

  Widget _actionsCell(TaskRowData row) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _smallButton('Assign'),
        const SizedBox(width: 6),
        _smallButton('Reassign'),
        const SizedBox(width: 6),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppStyles.borderSoft),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(6),
            minimumSize: const Size(32, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: () {},
          child: const Icon(Icons.more_horiz, size: 18),
        ),
      ],
    );
  }

  Widget _smallButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF24242B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: () {},
      child: Text(label),
    );
  }
}

class TaskMobileCard extends StatelessWidget {
  final TaskRowData row;
  const TaskMobileCard({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppStyles.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                row.agentName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppStyles.accentRose.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppStyles.accentRose),
                ),
                child: Text(
                  row.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            row.postTitle,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.priority_high,
                size: 14,
                color: AppStyles.mutedText,
              ),
              const SizedBox(width: 4),
              Text(
                'Priority: ${row.priority}',
                style: const TextStyle(
                  color: AppStyles.mutedText,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(Icons.timer, size: 14, color: Colors.orangeAccent),
              const SizedBox(width: 4),
              Text(
                row.slaShort,
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppStyles.borderSoft),
              ),
              onPressed: () {},
              child: const Text(
                'View Actions',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
