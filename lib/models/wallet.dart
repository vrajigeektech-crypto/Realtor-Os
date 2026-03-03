/// Wallet model from RPC: get_all_wallets_for_user
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

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'wallet_type': walletType,
      'balance': balance,
      'org_id': orgId,
      'agent_id': agentId,
    };
  }
}

/// Wallet balance model from RPC: get_wallet_balance
class WalletBalance {
  final int balance;

  WalletBalance({required this.balance});

  factory WalletBalance.fromRpcJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
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

/// Token breakdown from RPC: get_wallet_token_breakdown
class TokenBreakdown {
  final int earnedTokens;
  final int purchasedTokens;
  final int expiredTokens;

  TokenBreakdown({
    required this.earnedTokens,
    required this.purchasedTokens,
    required this.expiredTokens,
  });

  factory TokenBreakdown.fromRpcJson(Map<String, dynamic> json) {
    return TokenBreakdown(
      earnedTokens: (json['earned_tokens'] as num?)?.toInt() ?? 0,
      purchasedTokens: (json['purchased_tokens'] as num?)?.toInt() ?? 0,
      expiredTokens: (json['expired_tokens'] as num?)?.toInt() ?? 0,
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
}

/// Extended wallet transaction from RPC: get_wallet_transactions_extended
class ExtendedWalletTransaction {
  final String date;
  final String timeAgo;
  final String actionType;
  final String actor;
  final String dealLead;
  final String fundingSource;
  final double amount;
  final bool isPositive;
  final String outcome;

  ExtendedWalletTransaction({
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

  factory ExtendedWalletTransaction.fromRpcJson(Map<String, dynamic> json) {
    return ExtendedWalletTransaction(
      date: json['date'] as String? ?? '',
      timeAgo: json['time_ago'] as String? ?? '',
      actionType: json['action_type'] as String? ?? '',
      actor: json['actor'] as String? ?? '',
      dealLead: json['deal_lead'] as String? ?? '',
      fundingSource: json['funding_source'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isPositive: json['is_positive'] as bool? ?? false,
      outcome: json['outcome'] as String? ?? '',
    );
  }
}
