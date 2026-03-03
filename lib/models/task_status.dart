enum TaskStatus {
  inProgress,
  queued,
  awaitingApproval,
  completed,
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.queued:
        return 'Queued';
      case TaskStatus.awaitingApproval:
        return 'Awaiting Approval';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}
