import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/agent_profile_card_stats.dart';
import '../models/user_list_item.dart';
import '../models/enhanced_user_list_item.dart';
// import '../models/agent_spending_models.dart'; // Removed as spending RPCs moved to AgentSpendingService
import 'supabase_service.dart';
import 'rpc_client.dart';

/// Service class for managing user/agent data
/// All data access goes through RPC calls
class UserService {
  final RpcClient _rpc;

  UserService() : _rpc = SupabaseService.instance.rpc;

  /// #DATA: get_agent_profile_header
  /// RPC: get_agent_profile_header
  /// Inputs: none
  /// Output: User
  Future<User> getAgentProfileHeader() async {
    try {
      final response = await _rpc.getAgentProfileHeader();
      return User.fromRpcJson(response);
    } catch (e) {
      throw Exception('Failed to fetch agent profile: $e');
    }
  }

  /// #DATA: update_agent_status
  /// RPC: update_agent_status
  /// Inputs: p_agent_id (uuid), p_status (text)
  /// Output: User (updated agent record)
  Future<User> updateAgentStatus({
    required String agentId,
    required String status,
  }) async {
    try {
      final response = await _rpc.updateAgentStatus(
        agentId: agentId,
        status: status,
      );
      // Note: RPC returns full agents row, but we need to map it
      // Assuming the response has similar structure to get_agent_profile_header
      return User.fromRpcJson(response);
    } catch (e) {
      throw Exception('Failed to update agent status: $e');
    }
  }

  /// #DATA: get_agent_profile_card_stats
  /// RPC: get_agent_profile_card_stats
  /// Inputs: none (uses auth.uid())
  /// Output: AgentProfileCardStats
  Future<AgentProfileCardStats> getAgentProfileCardStats() async {
    try {
      debugPrint('📡 [UserService] Calling get_agent_profile_card_stats...');
      final response = await _rpc.getAgentProfileCardStats();
      debugPrint('✅ [UserService] get_agent_profile_card_stats success');
      return AgentProfileCardStats.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [UserService] get_agent_profile_card_stats failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch agent profile card stats: $e');
    }
  }

  /// #DATA: get_users_list
  /// RPC: get_users_list (or get_all_users)
  /// Inputs: none (uses auth.uid() for permissions)
  /// Output: List<UserListItem>
  Future<List<UserListItem>> getUsersList() async {
    try {
      debugPrint('📡 [UserService] Calling get_users_list...');
      final response = await _rpc.callRpc('get_users_list');
      if (response == null) {
        throw Exception('get_users_list returned null');
      }

      List<dynamic> usersList;
      if (response is List) {
        usersList = response;
      } else if (response is Map && response.containsKey('users')) {
        usersList = response['users'] as List<dynamic>? ?? [];
      } else {
        debugPrint(
          '⚠️ [UserService] Unexpected response format: ${response.runtimeType}',
        );
        return [];
      }

      final users = usersList
          .map((user) {
            try {
              if (user is Map<String, dynamic>) {
                return UserListItem.fromJson(user);
              } else if (user is Map) {
                return UserListItem.fromJson(Map<String, dynamic>.from(user));
              }
              return null;
            } catch (e) {
              debugPrint('❌ [UserService] Error parsing user: $e');
              return null;
            }
          })
          .whereType<UserListItem>()
          .toList();

      debugPrint('✅ [UserService] Parsed ${users.length} users');
      return users;
    } catch (e, stackTrace) {
      debugPrint('❌ [UserService] get_users_list failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch users list: $e');
    }
  }

  /// #DATA: get_enhanced_users_list
  /// RPC: get_users_list (enhanced version with all fields)
  /// Inputs: none (uses auth.uid() for permissions)
  /// Output: List<EnhancedUserListItem>
  Future<List<EnhancedUserListItem>> getEnhancedUsersList() async {
    try {
      debugPrint('📡 [UserService] Calling get_enhanced_users_list...');
      final response = await _rpc.callRpc('get_users_list');
      if (response == null) {
        throw Exception('get_users_list returned null');
      }

      List<dynamic> usersList;
      if (response is List) {
        usersList = response;
      } else if (response is Map && response.containsKey('users')) {
        usersList = response['users'] as List<dynamic>? ?? [];
      } else {
        debugPrint(
          '⚠️ [UserService] Unexpected response format: ${response.runtimeType}',
        );
        return [];
      }

      final users = usersList
          .map((user) {
            try {
              if (user is Map<String, dynamic>) {
                return EnhancedUserListItem.fromJson(user);
              } else if (user is Map) {
                return EnhancedUserListItem.fromJson(Map<String, dynamic>.from(user));
              }
              return null;
            } catch (e) {
              debugPrint('❌ [UserService] Error parsing enhanced user: $e');
              return null;
            }
          })
          .whereType<EnhancedUserListItem>()
          .toList();

      debugPrint('✅ [UserService] Parsed ${users.length} enhanced users');
      return users;
    } catch (e, stackTrace) {
      debugPrint('❌ [UserService] get_enhanced_users_list failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch enhanced users list: $e');
    }
  }

  /// #DATA: get_agent_profile
  /// RPC: get_agent_profile
  /// Inputs: none
  /// Output: Map with agent and brokerage info
  Future<Map<String, dynamic>> getAgentProfile() async {
    try {
      debugPrint('📡 [UserService] Calling get_agent_profile...');
      final response = await _rpc.getAgentProfile();
      debugPrint('✅ [UserService] get_agent_profile success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [UserService] get_agent_profile failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch agent profile: $e');
    }
  }

  /// #DATA: current_user_is_admin
  /// RPC: current_user_is_admin
  /// Inputs: none
  /// Output: boolean
  Future<bool> currentUserIsAdmin() async {
    try {
      debugPrint('📡 [UserService] Calling current_user_is_admin...');
      final response = await _rpc.currentUserIsAdmin();
      debugPrint('✅ [UserService] current_user_is_admin success: $response');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [UserService] current_user_is_admin failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to check admin status: $e');
    }
  }
}
