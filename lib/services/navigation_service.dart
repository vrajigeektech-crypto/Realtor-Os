import '../models/nav_tab.dart';
import 'supabase_service.dart';
import 'rpc_client.dart';

/// Service class for managing navigation data
/// All data access goes through RPC calls
class NavigationService {
  final RpcClient _rpc;

  NavigationService() : _rpc = SupabaseService.instance.rpc;

  /// #DATA: get_agent_nav_tabs
  /// RPC: get_agent_nav_tabs
  /// Inputs: none
  /// Output: List<NavTab>
  Future<List<NavTab>> getAgentNavTabs() async {
    try {
      final response = await _rpc.getAgentNavTabs();
      return response.map((json) => NavTab.fromRpcJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch nav tabs: $e');
    }
  }

  /// #DATA: get_active_tab_state
  /// RPC: get_active_tab_state
  /// Inputs: none (uses request header x-tab if present)
  /// Output: String (overview | wallet | tasks | settings)
  Future<String> getActiveTabState() async {
    try {
      return await _rpc.getActiveTabState();
    } catch (e) {
      throw Exception('Failed to fetch active tab state: $e');
    }
  }
}
