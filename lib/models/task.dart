import 'task_status.dart';
import 'task_priority.dart';

class Task {
  final String id; // Changed from int to String to match UUID format
  final String taskType;
  final TaskStatus status;
  final TaskPriority priority;
  final String slaCountdown;
  final int queuePosition;
  final String assignedAdmin;

  Task({
    required this.id,
    required this.taskType,
    required this.status,
    required this.priority,
    required this.slaCountdown,
    required this.queuePosition,
    required this.assignedAdmin,
  });

  // Factory constructor from RPC: get_task_queue_table
  // RPC Output: { id, task_type, status, priority, sla_countdown, queue_position, assigned_admin_id, assigned_admin_name }
  factory Task.fromRpcJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] as String? ?? '').toLowerCase();
    final priorityStr = (json['priority'] as String? ?? '').toLowerCase();
    
    // Map status string to enum (actual values: 'open', 'waiting_admin', 'complete')
    TaskStatus status;
    if (statusStr == 'open') {
      status = TaskStatus.inProgress;
    } else if (statusStr == 'waiting_admin') {
      status = TaskStatus.awaitingApproval;
    } else if (statusStr == 'complete') {
      status = TaskStatus.completed;
    } else {
      // Fallback for any other status
      status = TaskStatus.queued;
    }

    // Map priority string to enum (priority is NULL in actual schema)
    TaskPriority priority;
    if (priorityStr.isEmpty) {
      priority = TaskPriority.normal; // Default when null/empty
    } else if (priorityStr.contains('boosted')) {
      priority = TaskPriority.boosted;
    } else if (priorityStr.contains('high')) {
      priority = TaskPriority.high;
    } else if (priorityStr.contains('low')) {
      priority = TaskPriority.low;
    } else {
      priority = TaskPriority.normal; // default
    }

    return Task(
      id: json['id'] as String? ?? '', // Keep as String (UUID)
      taskType: json['task_type'] as String? ?? '',
      status: status,
      priority: priority,
      slaCountdown: json['sla_countdown'] as String? ?? '—',
      queuePosition: json['queue_position'] as int? ?? 0,
      assignedAdmin: json['assigned_admin_name'] as String? ?? '',
    );
  }

  // Legacy fromJson for backward compatibility
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '', // Keep as String
      taskType: json['taskType'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
      ),
      slaCountdown: json['slaCountdown'] as String,
      queuePosition: json['queuePosition'] as int,
      assignedAdmin: json['assignedAdmin'] as String,
    );
  }

  // Convert to JSON (for future RPC integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskType': taskType,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'slaCountdown': slaCountdown,
      'queuePosition': queuePosition,
      'assignedAdmin': assignedAdmin,
    };
  }
}
