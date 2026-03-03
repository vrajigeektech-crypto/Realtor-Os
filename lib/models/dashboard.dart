/// Active tasks summary from RPC: get_active_tasks_summary
class ActiveTasksSummary {
  final int totalTasks;
  final int totalValue;
  final int inProgressTasks;
  final int inProgressValue;
  final int awaitingApprovalTasks;
  final int awaitingApprovalValue;

  ActiveTasksSummary({
    required this.totalTasks,
    required this.totalValue,
    required this.inProgressTasks,
    required this.inProgressValue,
    required this.awaitingApprovalTasks,
    required this.awaitingApprovalValue,
  });

  factory ActiveTasksSummary.fromRpcJson(Map<String, dynamic> json) {
    return ActiveTasksSummary(
      totalTasks: (json['total_tasks'] as num?)?.toInt() ?? 0,
      totalValue: (json['total_value'] as num?)?.toInt() ?? 0,
      inProgressTasks: (json['in_progress_tasks'] as num?)?.toInt() ?? 0,
      inProgressValue: (json['in_progress_value'] as num?)?.toInt() ?? 0,
      awaitingApprovalTasks: (json['awaiting_approval_tasks'] as num?)?.toInt() ?? 0,
      awaitingApprovalValue: (json['awaiting_approval_value'] as num?)?.toInt() ?? 0,
    );
  }
}

/// SLA metrics from RPC: get_sla_metrics
class SlaMetrics {
  final int recentSlaBreaches;
  final int tasksAtRisk;

  SlaMetrics({
    required this.recentSlaBreaches,
    required this.tasksAtRisk,
  });

  factory SlaMetrics.fromRpcJson(Map<String, dynamic> json) {
    return SlaMetrics(
      recentSlaBreaches: (json['recent_sla_breaches'] as num?)?.toInt() ?? 0,
      tasksAtRisk: (json['tasks_at_risk'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Agent milestones extended from RPC: get_agent_milestones_extended
class AgentMilestonesExtended {
  final double tokensEarned;
  final String lastSpendLabel;
  final int nextMilestoneAmount;
  final int nextMilestoneDays;
  final bool cardSetupComplete;
  final String cardLastFour;

  AgentMilestonesExtended({
    required this.tokensEarned,
    required this.lastSpendLabel,
    required this.nextMilestoneAmount,
    required this.nextMilestoneDays,
    required this.cardSetupComplete,
    required this.cardLastFour,
  });

  factory AgentMilestonesExtended.fromRpcJson(Map<String, dynamic> json) {
    return AgentMilestonesExtended(
      tokensEarned: (json['tokens_earned'] as num?)?.toDouble() ?? 0.0,
      lastSpendLabel: json['last_spend_label'] as String? ?? '',
      nextMilestoneAmount: (json['next_milestone_amount'] as num?)?.toInt() ?? 0,
      nextMilestoneDays: (json['next_milestone_days'] as num?)?.toInt() ?? 0,
      cardSetupComplete: json['card_setup_complete'] as bool? ?? false,
      cardLastFour: json['card_last_four'] as String? ?? '',
    );
  }
}

/// XP progress from RPC: get_xp_progress
class XpProgress {
  final String agentId;
  final int totalXp;
  final int currentLevel;
  final int nextLevelXp;

  XpProgress({
    required this.agentId,
    required this.totalXp,
    required this.currentLevel,
    required this.nextLevelXp,
  });

  factory XpProgress.fromRpcJson(Map<String, dynamic> json) {
    return XpProgress(
      agentId: json['agent_id'] as String? ?? '',
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      currentLevel: (json['current_level'] as num?)?.toInt() ?? 0,
      nextLevelXp: (json['next_level_xp'] as num?)?.toInt() ?? 0,
    );
  }
}
