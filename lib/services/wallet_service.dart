import 'package:flutter/foundation.dart';
import '../models/wallet.dart';
import 'supabase_service.dart';
import 'rpc_client.dart';

/// Service class for managing wallet data
/// All data access goes through RPC calls
class WalletService {
  final RpcClient _rpc;

  WalletService() : _rpc = SupabaseService.instance.rpc;

  /// #DATA: get_all_wallets_for_user
  /// RPC: get_all_wallets_for_user
  /// Inputs: p_user_id (uuid)
  /// Output: List<Wallet>
  Future<List<Wallet>> getAllWalletsForUser(String userId) async {
    debugPrint('🚀 WalletService.getWallets START');
    debugPrint('👤 User ID: $userId');
    debugPrint('📡 RPC params: {p_user_id: $userId}');
    try {
      final response = await _rpc.callRpc(
        'get_all_wallets_for_user_bypass',
        params: {'p_user_id': userId},
      );
      debugPrint('✅ RPC raw response: $response');
      if (response == null) {
        debugPrint('❌ No wallets found');
        throw Exception('get_all_wallets_for_user returned null');
      }
      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          final d = response['data'];
          rawList = d is List ? d : [d];
        } else if (response.containsKey('wallets')) {
          final w = response['wallets'];
          rawList = w is List ? w : [w];
        } else {
          rawList = [response];
        }
      }
      final List<Map<String, dynamic>> maps = [];
      for (final e in rawList) {
        if (e is! Map<String, dynamic>) continue;
        final m = e;
        final uid = m['user_id']?.toString();
        if (uid != null && uid != userId) continue;
        final walletId = m['wallet_id'] ?? m['id']?.toString();
        if (walletId == null) continue;
        maps.add({
          'wallet_id': walletId.toString(),
          'wallet_type': m['wallet_type'] ?? 'agent',
          'balance': m['balance'] ?? m['balance_tokens'] ?? 0,
          'org_id': m['org_id'],
          'agent_id': m['agent_id'],
        });
      }
      debugPrint('🔍 Parsed wallet count: ${maps.length}');
      if (maps.isEmpty) {
        debugPrint('❌ No wallets found');
        debugPrint('✅ RPC raw response: $response');
        throw Exception(
          'No wallets returned for user. RPC response: $response',
        );
      }
      final wallets = maps.map((m) => Wallet.fromRpcJson(m)).toList();
      debugPrint('✅ WalletService.getWallets END');
      return wallets;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_all_wallets_for_user failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch wallets: $e');
    }
  }

  /// #DATA: get_wallet_balance
  /// RPC: get_wallet_balance
  /// Inputs: p_wallet_id (uuid)
  /// Output: WalletBalance
  Future<int> getWalletBalance(String walletId) async {
    try {
      debugPrint(
        '📡 [RPC] Calling get_wallet_balance with walletId: $walletId',
      );
      final response = await _rpc.callRpc(
        'get_wallet_balance',
        params: {'p_wallet_id': walletId},
      );
      if (response == null) {
        throw Exception('get_wallet_balance returned null');
      }
      debugPrint('✅ [RPC] get_wallet_balance success');
      final balance = WalletBalance.fromRpcJson(
        response as Map<String, dynamic>,
      );
      return balance.balance;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_wallet_balance failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch wallet balance: $e');
    }
  }

  /// #DATA: get_wallet_history
  /// RPC: get_wallet_history
  /// Inputs: p_wallet_id (uuid)
  /// Output: List<WalletHistoryEntry>
  Future<List<WalletHistoryEntry>> getWalletHistory(String walletId) async {
    try {
      debugPrint(
        '📡 [RPC] Calling get_wallet_history with walletId: $walletId',
      );
      final response = await _rpc.callRpc(
        'get_wallet_history',
        params: {'p_wallet_id': walletId},
      );
      if (response == null) {
        throw Exception('get_wallet_history returned null');
      }
      final List<dynamic> historyList = response is List
          ? response
          : response is Map
          ? [response]
          : [];
      debugPrint(
        '✅ [RPC] get_wallet_history success: ${historyList.length} entries',
      );
      return historyList
          .map(
            (json) =>
                WalletHistoryEntry.fromRpcJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_wallet_history failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch wallet history: $e');
    }
  }

  /// #DATA: get_wallet_token_breakdown
  /// RPC: get_wallet_token_breakdown
  /// Inputs: p_wallet_id (uuid)
  /// Output: TokenBreakdown
  Future<TokenBreakdown> getWalletTokenBreakdown(String walletId) async {
    try {
      debugPrint(
        '📡 [RPC] Calling get_wallet_token_breakdown with walletId: $walletId',
      );
      final response = await _rpc.callRpc(
        'get_wallet_token_breakdown',
        params: {'p_wallet_id': walletId},
      );
      if (response == null) {
        throw Exception('get_wallet_token_breakdown returned null');
      }
      debugPrint('✅ [RPC] get_wallet_token_breakdown success');
      return TokenBreakdown.fromRpcJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_wallet_token_breakdown failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch token breakdown: $e');
    }
  }

  /// #DATA: get_wallet_transactions
  /// RPC: get_wallet_transactions
  /// Inputs: p_wallet_id (uuid)
  /// Output: List<WalletTransaction>
  Future<List<WalletTransaction>> getWalletTransactions(String walletId) async {
    try {
      debugPrint(
        '📡 [RPC] Calling get_wallet_transactions with walletId: $walletId',
      );
      final response = await _rpc.callRpc(
        'get_wallet_transactions',
        params: {'p_wallet_id': walletId},
      );
      if (response == null) {
        throw Exception('get_wallet_transactions returned null');
      }
      final List<dynamic> transactionsList = response is List
          ? response
          : response is Map
          ? [response]
          : [];
      debugPrint(
        '✅ [RPC] get_wallet_transactions success: ${transactionsList.length} transactions',
      );
      return transactionsList
          .map(
            (json) =>
                WalletTransaction.fromRpcJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_wallet_transactions failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch wallet transactions: $e');
    }
  }

  /// #DATA: get_expiring_soon
  /// RPC: get_expiring_soon
  /// Inputs: p_wallet_id (uuid), p_days (integer)
  /// Output: int (token_count)
  Future<int> getExpiringSoon(String walletId, int days) async {
    try {
      debugPrint(
        '📡 [RPC] Calling get_expiring_soon with walletId: $walletId, days: $days',
      );
      final response = await _rpc.callRpc(
        'get_expiring_soon',
        params: {'p_wallet_id': walletId, 'p_days': days},
      );
      if (response == null) {
        throw Exception('get_expiring_soon returned null');
      }
      final tokenCount =
          (response as Map<String, dynamic>)['token_count'] as int? ?? 0;
      debugPrint('✅ [RPC] get_expiring_soon success: $tokenCount tokens');
      return tokenCount;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_expiring_soon failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch expiring tokens: $e');
    }
  }

  /// #DATA: get_wallet_reserved_tokens
  /// RPC: get_wallet_reserved_tokens
  /// Inputs: p_wallet_id (uuid)
  /// Output: double (reserved_tokens)
  Future<double> getWalletReservedTokens(String walletId) async {
    try {
      debugPrint(
        '📡 [RPC] Calling get_wallet_reserved_tokens with walletId: $walletId',
      );
      final response = await _rpc.callRpc(
        'get_wallet_reserved_tokens',
        params: {'p_wallet_id': walletId},
      );
      if (response == null) {
        throw Exception('get_wallet_reserved_tokens returned null');
      }
      final reservedTokens =
          (response as Map<String, dynamic>)['reserved_tokens'] as num?;
      debugPrint('✅ [RPC] get_wallet_reserved_tokens success');
      return reservedTokens?.toDouble() ?? 0.0;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_wallet_reserved_tokens failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch reserved tokens: $e');
    }
  }

  /// #DATA: get_wallet_spent_today
  /// RPC: get_wallet_spent_today
  /// Inputs: p_wallet_id (uuid)
  /// Output: double (spent_today)
  Future<double> getWalletSpentToday(String walletId) async {
    try {
      debugPrint(
        '📡 [RPC] Calling get_wallet_spent_today with walletId: $walletId',
      );
      final response = await _rpc.callRpc(
        'get_wallet_spent_today',
        params: {'p_wallet_id': walletId},
      );
      if (response == null) {
        throw Exception('get_wallet_spent_today returned null');
      }
      final spentToday =
          (response as Map<String, dynamic>)['spent_today'] as num?;
      debugPrint('✅ [RPC] get_wallet_spent_today success');
      return spentToday?.toDouble() ?? 0.0;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_wallet_spent_today failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch spent today: $e');
    }
  }

  /// #DATA: get_wallet_transactions_extended
  /// RPC: get_wallet_transactions_extended
  /// Inputs: p_wallet_id (uuid), p_time_filter (text)
  /// Output: List<ExtendedWalletTransaction>
  Future<List<ExtendedWalletTransaction>> getWalletTransactionsExtended(
    String walletId,
    String timeFilter,
  ) async {
    try {
      debugPrint(
        '📡 [RPC] Calling get_wallet_transactions_extended with walletId: $walletId, filter: $timeFilter',
      );
      final response = await _rpc.callRpc(
        'get_wallet_transactions_extended',
        params: {'p_wallet_id': walletId, 'p_time_filter': timeFilter},
      );
      if (response == null) {
        throw Exception('get_wallet_transactions_extended returned null');
      }
      final List<dynamic> transactionsList = response is List
          ? response
          : response is Map
          ? [response]
          : [];
      debugPrint(
        '✅ [RPC] get_wallet_transactions_extended success: ${transactionsList.length} transactions',
      );
      return transactionsList
          .map(
            (json) => ExtendedWalletTransaction.fromRpcJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_wallet_transactions_extended failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch extended transactions: $e');
    }
  }

  /// #DATA: get_active_tasks_summary
  /// RPC: get_active_tasks_summary
  /// Inputs: p_user_id (uuid)
  /// Output: Map<String, dynamic>
  Future<Map<String, dynamic>> getActiveTasksSummary(String userId) async {
    try {
      debugPrint(
        '📡 [RPC] Calling get_active_tasks_summary with userId: $userId',
      );
      final response = await _rpc.callRpc(
        'get_active_tasks_summary',
        params: {'p_user_id': userId},
      );
      if (response == null) {
        throw Exception('get_active_tasks_summary returned null');
      }
      debugPrint('✅ [RPC] get_active_tasks_summary success');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_active_tasks_summary failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch active tasks summary: $e');
    }
  }

  /// #DATA: get_sla_metrics
  /// RPC: get_sla_metrics
  /// Inputs: p_user_id (uuid)
  /// Output: Map<String, dynamic>
  Future<Map<String, dynamic>> getSlaMetrics(String userId) async {
    try {
      debugPrint('📡 [RPC] Calling get_sla_metrics with userId: $userId');
      final response = await _rpc.callRpc(
        'get_sla_metrics',
        params: {'p_user_id': userId},
      );
      if (response == null) {
        throw Exception('get_sla_metrics returned null');
      }
      debugPrint('✅ [RPC] get_sla_metrics success');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_sla_metrics failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch SLA metrics: $e');
    }
  }

  /// #DATA: get_xp_progress
  /// RPC: get_xp_progress
  /// Inputs: p_user_id (uuid)
  /// Output: Map<String, dynamic>
  Future<Map<String, dynamic>> getXpProgress(String userId) async {
    try {
      debugPrint('📡 [RPC] Calling get_xp_progress with userId: $userId');
      final response = await _rpc.callRpc(
        'get_xp_progress',
        params: {'p_user_id': userId},
      );
      if (response == null) {
        throw Exception('get_xp_progress returned null');
      }
      debugPrint('✅ [RPC] get_xp_progress success');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_xp_progress failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch XP progress: $e');
    }
  }

  /// #DATA: get_agent_milestones_extended
  /// RPC: get_agent_milestones_extended
  /// Inputs: p_user_id (uuid)
  /// Output: Map<String, dynamic>
  Future<Map<String, dynamic>> getAgentMilestonesExtended(String userId) async {
    try {
      debugPrint(
        '📡 [RPC] Calling get_agent_milestones_extended with userId: $userId',
      );
      final response = await _rpc.callRpc(
        'get_agent_milestones_extended',
        params: {'p_user_id': userId},
      );
      if (response == null) {
        throw Exception('get_agent_milestones_extended returned null');
      }
      debugPrint('✅ [RPC] get_agent_milestones_extended success');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_agent_milestones_extended failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch agent milestones extended: $e');
    }
  }
}
