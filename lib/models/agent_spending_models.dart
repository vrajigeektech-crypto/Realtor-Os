/// Agent Wallet Balances model from RPC: get_agent_wallet_balances
class AgentWalletBalances {
  final int availableBalance;
  final int committedTokens;
  final int spendInQueue;
  final int lifetimeSpendTotal;
  final int spendThisMonth;

  AgentWalletBalances({
    required this.availableBalance,
    required this.committedTokens,
    required this.spendInQueue,
    required this.lifetimeSpendTotal,
    required this.spendThisMonth,
  });

  factory AgentWalletBalances.fromJson(Map<String, dynamic> json) {
    return AgentWalletBalances(
      availableBalance: json['available_balance'] as int? ?? 0,
      committedTokens: json['committed_tokens'] as int? ?? 0,
      spendInQueue: json['spend_in_queue'] as int? ?? 0,
      lifetimeSpendTotal: json['lifetime_spend_total'] as int? ?? 0,
      spendThisMonth: json['spend_this_month'] as int? ?? 0,
    );
  }

  String formatCurrency(int value) {
    return '\$${value.toStringAsFixed(2)}';
  }
}

/// Spend Category Breakdown model from RPC: get_spend_breakdown_by_category
class SpendCategory {
  final String categoryId;
  final String categoryName;
  final int totalAmount;

  SpendCategory({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
  });

  factory SpendCategory.fromJson(Map<String, dynamic> json) {
    // Handle both RPC formats:
    // 1. get_spend_breakdown_by_category: { category_id, category_name, total_amount }
    // 2. get_agent_spend_summary_admin: { category, total_tokens }
    final categoryId = json['category_id'] as String? ?? json['category'] as String? ?? '';
    final categoryName = json['category_name'] as String? ?? json['category'] as String? ?? '';
    final totalAmount = json['total_amount'] as int? ?? json['total_tokens'] as int? ?? 0;
    
    return SpendCategory(
      categoryId: categoryId,
      categoryName: categoryName,
      totalAmount: totalAmount,
    );
  }

  String get formattedAmount => '\$${totalAmount.toStringAsFixed(2)}';
  
  double getFraction(double maxAmount) {
    if (maxAmount == 0) return 0.0;
    return (totalAmount / maxAmount).clamp(0.0, 1.0);
  }
}
