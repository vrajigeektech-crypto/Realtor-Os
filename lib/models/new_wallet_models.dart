/// New wallet models for REALTOR OS WALLET + EXECUTION SYSTEM
/// All models match RPC structure exactly - no calculations in Flutter

/// Wallet from RPC: get_all_wallets_for_user
class Wallet {
  final String walletId;
  final String walletType;
  final int balance;
  final String? orgId;
  final String? agentId;

  Wallet({
    required this.walletId,
    required this.walletType,
    required this.balance,
    this.orgId,
    this.agentId,
  });

  factory Wallet.fromRpcJson(Map<String, dynamic> json) {
    return Wallet(
      walletId: json['wallet_id'] as String,
      walletType: json['wallet_type'] as String,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      orgId: json['org_id'] as String?,
      agentId: json['agent_id'] as String?,
    );
  }
}

/// Wallet balance from RPC: get_wallet_balance
/// This is AVAILABLE balance only - commitments already subtracted
class WalletBalance {
  final int balance;

  WalletBalance({required this.balance});

  factory WalletBalance.fromRpcJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: (json['get_wallet_balance'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Wallet history entry from RPC: get_wallet_history
class WalletHistoryEntry {
  final DateTime day;
  final int netChange;
  final int runningBalance;

  WalletHistoryEntry({
    required this.day,
    required this.netChange,
    required this.runningBalance,
  });

  factory WalletHistoryEntry.fromRpcJson(Map<String, dynamic> json) {
    return WalletHistoryEntry(
      day: DateTime.parse(json['day'] as String),
      netChange: (json['net_change'] as num?)?.toInt() ?? 0,
      runningBalance: (json['running_balance'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Wallet transaction from RPC: get_wallet_transactions
class WalletTransaction {
  final DateTime createdAt;
  final String entryType;
  final int amount;
  final String source;

  WalletTransaction({
    required this.createdAt,
    required this.entryType,
    required this.amount,
    required this.source,
  });

  factory WalletTransaction.fromRpcJson(Map<String, dynamic> json) {
    return WalletTransaction(
      createdAt: DateTime.parse(json['created_at'] as String),
      entryType: json['entry_type'] as String,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      source: json['source'] as String? ?? '',
    );
  }

  /// Map entry_type to display labels
  String get displayLabel {
    switch (entryType) {
      case 'earn':
        return 'Tokens Earned';
      case 'spend':
        return 'Tokens Spent';
      case 'purchase':
        return 'Tokens Purchased';
      case 'transfer':
        return 'Tokens Transferred';
      default:
        return entryType;
    }
  }
}

/// Wallet commitment summary from RPC: get_wallet_commitments_summary
class WalletCommitmentSummary {
  final String commitmentType;
  final int totalReservedAmount;

  WalletCommitmentSummary({
    required this.commitmentType,
    required this.totalReservedAmount,
  });

  factory WalletCommitmentSummary.fromRpcJson(Map<String, dynamic> json) {
    return WalletCommitmentSummary(
      commitmentType: json['commitment_type'] as String,
      totalReservedAmount: (json['total_reserved_amount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Map commitment_type to display labels
  String get displayLabel {
    switch (commitmentType) {
      case 'ai_cleanup':
        return 'AI Cleanup';
      case 'live_transfer':
        return 'Live Transfer';
      case 'broker_funded':
        return 'Broker-Funded Tasks';
      case 'purchase_asset':
        return 'Asset Purchase';
      default:
        return commitmentType.replaceAll('_', ' ').toUpperCase();
    }
  }
}

/// Recommended intervention from RPC: get_recommended_interventions
class RecommendedIntervention {
  final String interventionType;
  final String description;
  final int tokenCost;
  final String actionKey;

  RecommendedIntervention({
    required this.interventionType,
    required this.description,
    required this.tokenCost,
    required this.actionKey,
  });

  factory RecommendedIntervention.fromRpcJson(Map<String, dynamic> json) {
    return RecommendedIntervention(
      interventionType: json['intervention_type'] as String,
      description: json['description'] as String,
      tokenCost: (json['token_cost'] as num?)?.toInt() ?? 0,
      actionKey: json['action_key'] as String,
    );
  }

  /// Get button text based on intervention type
  String get buttonText {
    switch (actionKey) {
      case 'activate_ai_cleanup':
        return 'Activate AI Cleanup';
      case 'escalate_live_call':
        return 'Escalate to Live Call';
      default:
        return 'Execute Action';
    }
  }
}

/// Operational trust level from RPC: get_operational_trust
class OperationalTrust {
  final int currentLevel;
  final int nextLevel;
  final int progressPercent;

  OperationalTrust({
    required this.currentLevel,
    required this.nextLevel,
    required this.progressPercent,
  });

  factory OperationalTrust.fromRpcJson(Map<String, dynamic> json) {
    return OperationalTrust(
      currentLevel: (json['current_level'] as num?)?.toInt() ?? 0,
      nextLevel: (json['next_level'] as num?)?.toInt() ?? 0,
      progressPercent: (json['progress_percent'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Automation summary from RPC: get_automation_summary
class AutomationSummary {
  final String vaStatus;
  final int activeAssignmentsCount;
  final int runningTasksCount;

  AutomationSummary({
    required this.vaStatus,
    required this.activeAssignmentsCount,
    required this.runningTasksCount,
  });

  factory AutomationSummary.fromRpcJson(Map<String, dynamic> json) {
    return AutomationSummary(
      vaStatus: json['va_status'] as String? ?? 'offline',
      activeAssignmentsCount: (json['active_assignments_count'] as num?)?.toInt() ?? 0,
      runningTasksCount: (json['running_tasks_count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Get VA status display
  String get vaStatusDisplay {
    switch (vaStatus) {
      case 'online':
        return 'Online';
      case 'offline':
        return 'Offline';
      case 'busy':
        return 'Busy';
      default:
        return vaStatus;
    }
  }
}

/// Execute action response from RPC: execute_action
class ExecuteActionResponse {
  final bool success;
  final String? commitmentId;
  final String? taskId;
  final String message;

  ExecuteActionResponse({
    required this.success,
    this.commitmentId,
    this.taskId,
    required this.message,
  });

  factory ExecuteActionResponse.fromRpcJson(Map<String, dynamic> json) {
    return ExecuteActionResponse(
      success: json['success'] as bool? ?? false,
      commitmentId: json['commitment_id'] as String?,
      taskId: json['task_id'] as String?,
      message: json['message'] as String? ?? '',
    );
  }
}

/// Complete task response from RPC: complete_task
class CompleteTaskResponse {
  final bool success;
  final String message;

  CompleteTaskResponse({
    required this.success,
    required this.message,
  });

  factory CompleteTaskResponse.fromRpcJson(Map<String, dynamic> json) {
    return CompleteTaskResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

/// Wallet Health metrics (calculated from multiple RPCs)
/// Frontend combines data - no math here
class WalletHealth {
  final int availableTokens;
  final int reservedTokens;
  final int tokensSpentLast30Days;
  final int expiringNext7Days;

  WalletHealth({
    required this.availableTokens,
    required this.reservedTokens,
    required this.tokensSpentLast30Days,
    required this.expiringNext7Days,
  });
}
