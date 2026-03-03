/// Agent Task Item model for task dropdown
/// Used in Task Audit Log screen to display available tasks
class AgentTaskItem {
  final String taskId;
  final int? taskNumber; // Integer from RPC
  final String title;
  final String status;
  final DateTime createdAt;

  AgentTaskItem({
    required this.taskId,
    required this.taskNumber,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  factory AgentTaskItem.fromJson(Map<String, dynamic> json) {
    // Parse created_at
    DateTime createdAt;
    final createdAtStr = json['created_at'] as String?;
    if (createdAtStr != null) {
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (e) {
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }

    // Parse task_number as int
    int? taskNumber;
    final taskNumberValue = json['task_number'] ?? json['taskNumber'];
    if (taskNumberValue != null) {
      if (taskNumberValue is int) {
        taskNumber = taskNumberValue;
      } else if (taskNumberValue is String) {
        taskNumber = int.tryParse(taskNumberValue);
      } else if (taskNumberValue is num) {
        taskNumber = taskNumberValue.toInt();
      }
    }

    return AgentTaskItem(
      taskId: json['task_id'] as String? ?? json['taskId'] as String? ?? '',
      taskNumber: taskNumber,
      title: json['title'] as String? ?? 'Untitled Task',
      status: json['status'] as String? ?? 'open',
      createdAt: createdAt,
    );
  }

  /// Format for display: "Task #[number] - [title]" (truncate title if > 50 chars)
  String get displayText {
    final truncatedTitle = title.length > 50 ? '${title.substring(0, 47)}...' : title;
    final numberStr = taskNumber?.toString() ?? '';
    return 'Task #$numberStr - $truncatedTitle';
  }
}
