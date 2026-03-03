// agent_wallet_models.dart

class WalletSummary {
  final double balance;
  final double reservedTokens;
  final double spentToday;

  WalletSummary({
    required this.balance,
    required this.reservedTokens,
    required this.spentToday,
  });
}

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
}

class SLAMetrics {
  final int recentSlaBreaches;
  final int tasksAtRisk;
  final int xpEarned;
  final int nextLevelXp;

  SLAMetrics({
    required this.recentSlaBreaches,
    required this.tasksAtRisk,
    required this.xpEarned,
    required this.nextLevelXp,
  });
}

class AgentMilestones {
  final int currentXp;
  final int nextLevelXp;
  final double tokensEarned;
  final String lastSpendLabel;
  final int nextMilestoneAmount;
  final int nextMilestoneDays;
  final bool cardSetupComplete;
  final String cardLastFour;

  AgentMilestones({
    required this.currentXp,
    required this.nextLevelXp,
    required this.tokensEarned,
    required this.lastSpendLabel,
    required this.nextMilestoneAmount,
    required this.nextMilestoneDays,
    required this.cardSetupComplete,
    required this.cardLastFour,
  });
}

class LedgerEntry {
  final String date;
  final String timeAgo;
  final String actionType;
  final String actor;
  final String dealLead;
  final String fundingSource;
  final double amount;
  final bool isPositive;
  final String outcome;

  LedgerEntry({
    required this.date,
    required this.timeAgo,
    required this.actionType,
    required this.actor,
    required this.dealLead,
    required this.fundingSource,
    required this.amount,
    required this.isPositive,
    required this.outcome,
  });
}
