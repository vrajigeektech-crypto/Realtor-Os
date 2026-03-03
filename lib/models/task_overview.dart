class TaskOverview {
  final int totalOpenTasks;
  final int awaitingApproval;
  final int slaBreachesToday;

  TaskOverview({
    required this.totalOpenTasks,
    required this.awaitingApproval,
    required this.slaBreachesToday,
  });

  // Factory constructor from RPC: get_task_overview_counts
  // RPC Output: { total_open_tasks, awaiting_approval, sla_breaches_today }
  factory TaskOverview.fromRpcJson(Map<String, dynamic> json) {
    return TaskOverview(
      totalOpenTasks: json['total_open_tasks'] as int? ?? 0,
      awaitingApproval: json['awaiting_approval'] as int? ?? 0,
      slaBreachesToday: json['sla_breaches_today'] as int? ?? 0,
    );
  }

  // Legacy fromJson for backward compatibility
  factory TaskOverview.fromJson(Map<String, dynamic> json) {
    return TaskOverview(
      totalOpenTasks: json['totalOpenTasks'] as int,
      awaitingApproval: json['awaitingApproval'] as int,
      slaBreachesToday: json['slaBreachesToday'] as int,
    );
  }

  // Convert to JSON (for future RPC integration)
  Map<String, dynamic> toJson() {
    return {
      'totalOpenTasks': totalOpenTasks,
      'awaitingApproval': awaitingApproval,
      'slaBreachesToday': slaBreachesToday,
    };
  }
}
