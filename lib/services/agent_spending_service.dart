import 'package:flutter/foundation.dart';
import '../models/agent_spending_models.dart';
import 'supabase_service.dart';
import 'rpc_client.dart';

/// Service class for managing agent spending data
/// All data access goes through RPC calls
class AgentSpendingService {
  final RpcClient _rpc;

  AgentSpendingService() : _rpc = SupabaseService.instance.rpc;

  /// #DATA: get_agent_wallet_balances
  /// RPC: get_agent_wallet_balances
  /// Inputs: none
  /// Output: AgentWalletBalances
  Future<AgentWalletBalances> getAgentWalletBalances() async {
    try {
      debugPrint('📡 [AgentSpendingService] Calling get_agent_wallet_balances...');
      final response = await _rpc.getAgentWalletBalances();
      debugPrint('✅ [AgentSpendingService] get_agent_wallet_balances success');
      return AgentWalletBalances.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [AgentSpendingService] get_agent_wallet_balances failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch wallet balances: $e');
    }
  }

  /// #DATA: get_spend_breakdown_by_category
  /// RPC: get_spend_breakdown_by_category
  /// Inputs: none
  /// Output: List<SpendCategory>
  Future<List<SpendCategory>> getSpendBreakdownByCategory() async {
    try {
      debugPrint('📡 [AgentSpendingService] Calling get_spend_breakdown_by_category...');
      final response = await _rpc.getSpendBreakdownByCategory();
      debugPrint('✅ [AgentSpendingService] get_spend_breakdown_by_category success');
      return response
          .map((cat) => SpendCategory.fromJson(cat))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ [AgentSpendingService] get_spend_breakdown_by_category failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch spend breakdown: $e');
    }
  }

  /// #DATA: get_agent_spend_summary_admin
  /// RPC: get_agent_spend_summary_admin
  /// Inputs: p_agent_id (uuid)
  /// Output: AgentWalletBalances
  /// Note: Admin-only RPC. Requires admin, broker, or team_lead role.
  Future<AgentWalletBalances> getAgentSpendSummaryAdmin({
    required String agentId,
  }) async {
    try {
      debugPrint('📡 [AgentSpendingService] Calling get_agent_spend_summary_admin with agentId: $agentId');
      final response = await _rpc.getAgentSpendSummaryAdmin(agentId: agentId);
      debugPrint('✅ [AgentSpendingService] get_agent_spend_summary_admin success');
      debugPrint('   Response: $response');
      return AgentWalletBalances.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [AgentSpendingService] get_agent_spend_summary_admin failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch agent spend summary: $e');
    }
  }
}
