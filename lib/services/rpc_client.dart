import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// RPC Client for making database RPC calls
/// All RPC calls go through this service
/// FIX: Always uses Supabase.instance.client at call time to ensure auth context is current
class RpcClient {
  /// Get the current Supabase client instance at call time
  /// This ensures we always have the latest session/auth context
  SupabaseClient get _client => Supabase.instance.client;

  /// get_agent_profile_header
  /// Inputs: none
  /// Output: jsonb with agent profile data
  Future<Map<String, dynamic>> getAgentProfileHeader() async {
    try {
      debugPrint('📡 [RPC] Calling get_agent_profile_header...');
      final response = await _client.rpc('get_agent_profile_header');
      if (response == null) {
        throw Exception('get_agent_profile_header returned null');
      }
      debugPrint('✅ [RPC] get_agent_profile_header success');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_agent_profile_header failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception(
        'RPC call failed: $e. Make sure the function exists in your database.',
      );
    }
  }

  /// update_agent_status
  /// Inputs: p_agent_id (uuid), p_status (text)
  /// Output: agents row updated (full record)
  Future<Map<String, dynamic>> updateAgentStatus({
    required String agentId,
    required String status,
  }) async {
    try {
      final response = await _client.rpc(
        'update_agent_status',
        params: {'p_agent_id': agentId, 'p_status': status},
      );
      if (response == null) {
        throw Exception('update_agent_status returned null');
      }
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception(
        'RPC call failed: $e. Make sure the function exists in your database.',
      );
    }
  }

  /// get_agent_nav_tabs
  /// Inputs: none
  /// Output: jsonb array of nav tabs
  Future<List<Map<String, dynamic>>> getAgentNavTabs() async {
    try {
      final response = await _client.rpc('get_agent_nav_tabs');
      if (response == null) {
        throw Exception('get_agent_nav_tabs returned null');
      }
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception(
        'RPC call failed: $e. Make sure the function exists in your database.',
      );
    }
  }

  /// get_active_tab_state
  /// Inputs: none (uses request header x-tab if present)
  /// Output: text (overview | wallet | tasks | settings)
  /// Note: Custom headers need to be configured at Supabase client level
  /// For now, calling without headers - RPC should use default behavior
  Future<String> getActiveTabState() async {
    try {
      final response = await _client.rpc('get_active_tab_state');
      if (response == null) {
        throw Exception('get_active_tab_state returned null');
      }
      return response as String;
    } catch (e) {
      throw Exception(
        'RPC call failed: $e. Make sure the function exists in your database.',
      );
    }
  }

  /// get_task_queue_table
  /// Inputs: none
  /// Output: jsonb array of tasks
  Future<List<Map<String, dynamic>>> getTaskQueueTable() async {
    try {
      final response = await _client.rpc('get_task_queue_table');
      if (response == null) {
        throw Exception('get_task_queue_table returned null');
      }
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else if (response is Map) {
        // If it returns a single object, wrap it in a list
        return [response as Map<String, dynamic>];
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }
    } catch (e) {
      throw Exception(
        'RPC call failed: $e. Make sure the function "get_task_queue_table" exists in your database.',
      );
    }
  }

  /// view_task_detail
  /// Inputs: p_task_id (uuid)
  /// Output: tasks row (full record)
  Future<Map<String, dynamic>> viewTaskDetail(String taskId) async {
    try {
      debugPrint('📡 [RPC] Calling view_task_detail with taskId: $taskId');
      final response = await _client.rpc(
        'view_task_detail',
        params: {'p_task_id': taskId},
      );
      if (response == null) {
        throw Exception('view_task_detail returned null');
      }
      debugPrint('✅ [RPC] view_task_detail response: $response');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] view_task_detail failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception(
        'RPC call failed: $e. Make sure the function exists in your database.',
      );
    }
  }

  /// get_task_overview_counts
  /// Inputs: none
  /// Output: jsonb with task counts
  Future<Map<String, dynamic>> getTaskOverviewCounts() async {
    try {
      debugPrint('📡 [RPC] Calling get_task_overview_counts...');
      final response = await _client.rpc('get_task_overview_counts');
      if (response == null) {
        throw Exception('get_task_overview_counts returned null');
      }
      debugPrint('✅ [RPC] get_task_overview_counts success');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_task_overview_counts failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception(
        'RPC call failed: $e. Make sure the function exists in your database.',
      );
    }
  }

  /// get_agent_profile_card_stats
  /// Inputs: none (uses auth.uid())
  /// Output: jsonb with agent profile card stats
  Future<Map<String, dynamic>> getAgentProfileCardStats() async {
    try {
      debugPrint('📡 [RPC] Calling get_agent_profile_card_stats...');
      final response = await _client.rpc('get_agent_profile_card_stats');
      if (response == null) {
        throw Exception('get_agent_profile_card_stats returned null');
      }
      debugPrint('✅ [RPC] get_agent_profile_card_stats success');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_agent_profile_card_stats failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception(
        'RPC call failed: $e. Make sure the function exists in your database.',
      );
    }
  }

  /// get_agent_profile
  /// Inputs: none
  /// Output: jsonb with agent and brokerage info
  Future<Map<String, dynamic>> getAgentProfile() async {
    try {
      debugPrint('📡 [RPC] Calling get_agent_profile...');
      final response = await _client.rpc('get_agent_profile');
      if (response == null) {
        throw Exception('get_agent_profile returned null');
      }
      debugPrint('✅ [RPC] get_agent_profile success');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_agent_profile failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception(
        'RPC call failed: $e. Make sure the function exists in your database.',
      );
    }
  }

  /// current_user_is_admin
  /// Inputs: none
  /// Output: boolean (true if role = broker or team_lead)
  Future<bool> currentUserIsAdmin() async {
    try {
      debugPrint('📡 [RPC] Calling current_user_is_admin...');
      final response = await _client.rpc('current_user_is_admin');
      if (response == null) {
        throw Exception('current_user_is_admin returned null');
      }
      debugPrint('✅ [RPC] current_user_is_admin success');
      return response as bool;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] current_user_is_admin failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception(
        'RPC call failed: $e. Make sure the function exists in your database.',
      );
    }
  }

  /// get_agent_wallet_balances
  /// Inputs: none
  /// Output: jsonb with wallet balance data
  Future<Map<String, dynamic>> getAgentWalletBalances() async {
    try {
      debugPrint('📡 [RPC] Calling get_agent_wallet_balances...');
      final response = await _client.rpc('get_agent_wallet_balances');
      if (response == null) {
        throw Exception('get_agent_wallet_balances returned null');
      }
      debugPrint('✅ [RPC] get_agent_wallet_balances success');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_agent_wallet_balances failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception(
        'RPC call failed: $e. Make sure the function exists in your database.',
      );
    }
  }

  /// get_spend_breakdown_by_category
  /// Inputs: none
  /// Output: jsonb array of category breakdown
  Future<List<Map<String, dynamic>>> getSpendBreakdownByCategory() async {
    try {
      debugPrint('📡 [RPC] Calling get_spend_breakdown_by_category...');
      final response = await _client.rpc('get_spend_breakdown_by_category');
      if (response == null) {
        throw Exception('get_spend_breakdown_by_category returned null');
      }
      List<dynamic> categories;
      if (response is List) {
        categories = response;
      } else if (response is Map && response.containsKey('categories')) {
        categories = response['categories'] as List<dynamic>? ?? [];
      } else {
        debugPrint(
          '⚠️ [RPC] Unexpected response format: ${response.runtimeType}',
        );
        return [];
      }
      debugPrint('✅ [RPC] get_spend_breakdown_by_category success');
      return categories.map((c) => c as Map<String, dynamic>).toList();
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_spend_breakdown_by_category failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception(
        'RPC call failed: $e. Make sure the function exists in your database.',
      );
    }
  }

  /// get_agent_spend_summary_admin
  /// Inputs: p_agent_id (uuid)
  /// Output: Map with summary object containing:
  ///   - available_balance
  ///   - committed_tokens
  ///   - spend_in_queue
  ///   - lifetime_spend_total
  ///   - spend_this_month
  Future<Map<String, dynamic>> getAgentSpendSummaryAdmin({
    required String agentId,
  }) async {
    try {
      debugPrint(
        '📡 [RPC] Calling get_agent_spend_summary_admin with agentId: $agentId',
      );
      final response = await _client.rpc(
        'get_agent_spend_summary_admin',
        params: {'p_agent_id': agentId},
      );
      if (response == null) {
        throw Exception('get_agent_spend_summary_admin returned null');
      }

      // RPC returns: { available_balance, committed_tokens, spend_in_queue, lifetime_spend_total, spend_this_month }
      if (response is Map<String, dynamic>) {
        debugPrint('✅ [RPC] get_agent_spend_summary_admin success');
        debugPrint('   Response: $response');
        return response;
      } else {
        debugPrint(
          '⚠️ [RPC] Unexpected response format: ${response.runtimeType}',
        );
        throw Exception(
          'Unexpected response format: expected Map, got ${response.runtimeType}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_agent_spend_summary_admin failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception(
        'RPC call failed: $e. Make sure the function exists in your database.',
      );
    }
  }

  /// award_xp_for_event — awards XP for an event (idempotent per event_ref)
  /// Params: p_user_id (uuid), p_event_key (e.g. 'upload_logo'), p_event_ref (unique ref for idempotency)
  /// Returns: { awarded: bool, xp: int, reason?: string }
  Future<Map<String, dynamic>> awardXpForEvent({
    required String userId,
    required String eventKey,
    required String eventRef,
  }) async {
    try {
      final response = await _client.rpc(
        'award_xp_for_event',
        params: {
          'p_user_id': userId,
          'p_event_key': eventKey,
          'p_event_ref': eventRef,
        },
      );
      if (response == null) return {'awarded': false, 'xp': 0};
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ [RPC] award_xp_for_event failed: $e');
      return {'awarded': false, 'xp': 0};
    }
  }

  /// Generic RPC call method for wallet and dashboard services
  /// Inputs: functionName (String), params (Map<String, dynamic>?)
  /// Output: dynamic (can be Map, List, or primitive)
  Future<dynamic> callRpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    try {
      debugPrint('📡 [RPC] Calling $functionName with params: $params');
      final response = await _client.rpc(functionName, params: params);
      if (response == null) {
        throw Exception('$functionName returned null');
      }
      debugPrint('✅ [RPC] $functionName success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] $functionName failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception(
        'RPC call failed: $e. Make sure the function exists in your database.',
      );
    }
  }
}
