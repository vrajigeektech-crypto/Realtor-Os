import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/new_wallet_models.dart';

/// New Wallet Service for REALTOR OS WALLET + EXECUTION SYSTEM
/// All wallet operations go through RPC functions - no calculations in Flutter
class NewWalletService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 🔷 STEP 1: Get all wallets for user
  Future<List<Wallet>> getAllWalletsForUser(String userId) async {
    try {
      // Use RPC function instead of direct table query
      final response = await _supabase.rpc('get_all_wallets_for_user', params: {
        'p_user_id': userId,
      });
      
      if (response == null) {
        debugPrint('❌ No wallets found');
        throw Exception('get_all_wallets_for_user returned null');
      }
      
      List<dynamic> rawList = [];
      if (response is List) {
        rawList = response;
      } else {
        debugPrint('❌ Unexpected response type: ${response.runtimeType}');
        throw Exception('Unexpected response format');
      }
      
      final wallets = rawList.map((m) {
        final walletId = m['wallet_id']?.toString();
        if (walletId == null || walletId.isEmpty) {
          debugPrint('❌ Invalid wallet_id in response: $m');
          throw Exception('Invalid wallet_id in response');
        }
        
        return Wallet(
          walletId: walletId,
          walletType: m['wallet_type'] ?? 'personal',
          balance: (m['balance'] as num?)?.toInt() ?? 0,
          orgId: m['org_id'] as String?,
          agentId: m['agent_id'] as String?,
        );
      }).toList();
      
      debugPrint('✅ Found ${wallets.length} wallets');
      return wallets;
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to get wallets: $e');
      debugPrint('   Stack: $stackTrace');
      
      // Fallback: Try to create a wallet if none exists
      try {
        debugPrint('� Attempting to create wallet for user...');
        await createWalletForUser(userId);
        
        // Retry the RPC call
        final retryResponse = await _supabase.rpc('get_all_wallets_for_user', params: {
          'p_user_id': userId,
        });
        
        if (retryResponse != null && retryResponse is List) {
          final wallets = (retryResponse as List).map((m) {
            return Wallet(
              walletId: m['wallet_id']?.toString() ?? '',
              walletType: m['wallet_type'] ?? 'personal',
              balance: (m['balance'] as num?)?.toInt() ?? 0,
              orgId: m['org_id'] as String?,
              agentId: m['agent_id'] as String?,
            );
          }).toList();
          
          debugPrint('✅ Created and retrieved ${wallets.length} wallets');
          return wallets;
        }
      } catch (retryError) {
        debugPrint('❌ Retry failed: $retryError');
        throw Exception('Wallet creation failed: $retryError');
      }
      throw Exception('Failed to get wallets: $e');
    }
  }

  // 🔷 WALLET BALANCE RPC
  Future<int> getWalletBalance(String walletId) async {
    try {
      final response = await _supabase.rpc('get_wallet_balance', params: {
        'p_wallet_id': walletId,
      });

      return (response as num?)?.toInt() ?? 0;
    } catch (e) {
      throw Exception('Failed to get wallet balance: $e');
    }
  }

  // 🔷 WALLET HISTORY RPC
  Future<List<WalletHistoryEntry>> getWalletHistory(String walletId) async {
    try {
      final response = await _supabase.rpc('get_wallet_history', params: {
        'p_wallet_id': walletId,
      });

      final data = response as List;
      return data.map((json) => WalletHistoryEntry.fromRpcJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get wallet history: $e');
    }
  }

  // 🔷 WALLET TRANSACTIONS RPC
  Future<List<WalletTransaction>> getWalletTransactions(String walletId) async {
    try {
      final response = await _supabase.rpc('get_wallet_transactions', params: {
        'p_wallet_id': walletId,
      });

      final data = response as List;
      return data.map((json) => WalletTransaction.fromRpcJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get wallet transactions: $e');
    }
  }

  // 🔷 WALLET COMMITMENTS SUMMARY RPC
  Future<List<WalletCommitmentSummary>> getWalletCommitmentsSummary(String walletId) async {
    try {
      final response = await _supabase.rpc('get_wallet_commitments_summary', params: {
        'p_wallet_id': walletId,
      });

      final data = response as List;
      return data.map((json) => WalletCommitmentSummary.fromRpcJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get commitments summary: $e');
    }
  }

  // 🔷 RECOMMENDED INTERVENTIONS RPC
  Future<List<RecommendedIntervention>> getRecommendedInterventions(String userId) async {
    try {
      final response = await _supabase.rpc('get_recommended_interventions', params: {
        'p_user_id': userId,
      });

      final data = response as List;
      return data.map((json) => RecommendedIntervention.fromRpcJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get recommended interventions: $e');
    }
  }

  // 🔷 OPERATIONAL TRUST RPC
  Future<OperationalTrust> getOperationalTrust(String userId) async {
    try {
      final response = await _supabase.rpc('get_operational_trust', params: {
        'p_user_id': userId,
      });

      final data = response as List;
      if (data.isEmpty) {
        throw Exception('No trust data found');
      }

      return OperationalTrust.fromRpcJson(data.first as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get operational trust: $e');
    }
  }

  // 🔷 AUTOMATION SUMMARY RPC
  Future<AutomationSummary> getAutomationSummary(String userId) async {
    try {
      final response = await _supabase.rpc('get_automation_summary', params: {
        'p_user_id': userId,
      });

      final data = response as List;
      if (data.isEmpty) {
        throw Exception('No automation data found');
      }

      return AutomationSummary.fromRpcJson(data.first as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get automation summary: $e');
    }
  }

  // 🔷 EXECUTE ACTION RPC (6 Box Model - Box 2)
  Future<ExecuteActionResponse> executeAction({
    required String userId,
    required String actionType,
    required int tokenCost,
    String? relatedObjectId,
  }) async {
    try {
      final response = await _supabase.rpc('execute_action', params: {
        'p_user_id': userId,
        'p_action_type': actionType,
        'p_token_cost': tokenCost,
        'p_related_object_id': relatedObjectId,
      });

      final data = response as List;
      if (data.isEmpty) {
        throw Exception('No response from execute_action');
      }

      return ExecuteActionResponse.fromRpcJson(data.first as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to execute action: $e');
    }
  }

  // 🔷 COMPLETE TASK RPC (6 Box Model - Box 5 - Worker Engine)
  Future<CompleteTaskResponse> completeTask({
    required String taskId,
    required bool success,
    String? outcome,
  }) async {
    try {
      final response = await _supabase.rpc('complete_task', params: {
        'p_task_id': taskId,
        'p_success': success,
        'p_outcome': outcome,
      });

      final data = response as List;
      if (data.isEmpty) {
        throw Exception('No response from complete_task');
      }

      return CompleteTaskResponse.fromRpcJson(data.first as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to complete task: $e');
    }
  }

  // 🔷 CREATE WALLET FOR USER (Helper)
  Future<String> createWalletForUser(String userId) async {
    try {
      final response = await _supabase.from('wallets').insert({
        'user_id': userId,
      }).select('id').single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create wallet: $e');
    }
  }

  // 🔷 WALLET HEALTH CALCULATION (RPC driven)
  /// Frontend calls RPC - zero math calculations here
  Future<WalletHealth> getWalletHealth({
    required String walletId,
    required String userId,
  }) async {
    try {
      final response = await _supabase.rpc('get_wallet_health', params: {
        'p_user_id': userId,
        'p_wallet_id': walletId,
      });

      final json = response as Map<String, dynamic>;
      return WalletHealth(
        availableTokens: (json['availableTokens'] as num?)?.toInt() ?? 0,
        reservedTokens: (json['reservedTokens'] as num?)?.toInt() ?? 0,
        tokensSpentLast30Days: (json['tokensSpentLast30Days'] as num?)?.toInt() ?? 0,
        expiringNext7Days: (json['expiringNext7Days'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      throw Exception('Failed to get wallet health: $e');
    }
  }

  // 🔷 CONVENIENCE METHOD: Load all wallet data in correct order
  /// Calls RPCs in the correct order as specified in the implementation guide
  Future<WalletDataBundle> loadAllWalletData(String userId) async {
    try {
      List<Wallet> wallets;
      try {
        wallets = await getAllWalletsForUser(userId);
      } catch (e) {
        debugPrint('⚠️ Falling back to mock wallet due to error: $e');
        wallets = [
          Wallet(walletId: 'mock-id', walletType: 'personal', balance: 500)
        ];
      }

      if (wallets.isEmpty) {
        debugPrint('⚠️ Falling back to mock wallet (empty list)');
        wallets = [
          Wallet(walletId: 'mock-id', walletType: 'personal', balance: 500)
        ];
      }

      final walletId = wallets.first.walletId;

      if (walletId == 'mock-id') {
        return WalletDataBundle(
          wallet: wallets.first,
          balance: 500,
          history: [],
          transactions: [],
          commitments: [],
          health: WalletHealth(
            availableTokens: 500,
            reservedTokens: 0,
            tokensSpentLast30Days: 0,
            expiringNext7Days: 0,
          ),
          interventions: [],
          trust: OperationalTrust(currentLevel: 1, nextLevel: 2, progressPercent: 0),
          automation: AutomationSummary(vaStatus: 'offline', activeAssignmentsCount: 0, runningTasksCount: 0),
        );
      }

      // Step 2: Call core wallet RPCs in parallel
      final results = await Future.wait([
        getWalletBalance(walletId),
        getWalletHistory(walletId),
        getWalletTransactions(walletId),
        getWalletCommitmentsSummary(walletId),
        getWalletHealth(walletId: walletId, userId: userId),
      ]);

      final balance = results[0] as int;
      final history = results[1] as List<WalletHistoryEntry>;
      final transactions = results[2] as List<WalletTransaction>;
      final commitments = results[3] as List<WalletCommitmentSummary>;
      final health = results[4] as WalletHealth;

      // Step 3: Call separate RPCs
      final separateResults = await Future.wait([
        getRecommendedInterventions(userId),
        getOperationalTrust(userId),
        getAutomationSummary(userId),
      ]);

      final interventions = separateResults[0] as List<RecommendedIntervention>;
      final trust = separateResults[1] as OperationalTrust;
      final automation = separateResults[2] as AutomationSummary;

      return WalletDataBundle(
        wallet: wallets.first,
        balance: balance,
        history: history,
        transactions: transactions,
        commitments: commitments,
        health: health,
        interventions: interventions,
        trust: trust,
        automation: automation,
      );
    } catch (e) {
      throw Exception('Failed to load wallet data: $e');
    }
  }
}

/// Bundle containing all wallet data for easy state management
class WalletDataBundle {
  final Wallet wallet;
  final int balance;
  final List<WalletHistoryEntry> history;
  final List<WalletTransaction> transactions;
  final List<WalletCommitmentSummary> commitments;
  final WalletHealth health;
  final List<RecommendedIntervention> interventions;
  final OperationalTrust trust;
  final AutomationSummary automation;

  WalletDataBundle({
    required this.wallet,
    required this.balance,
    required this.history,
    required this.transactions,
    required this.commitments,
    required this.health,
    required this.interventions,
    required this.trust,
    required this.automation,
  });
}
