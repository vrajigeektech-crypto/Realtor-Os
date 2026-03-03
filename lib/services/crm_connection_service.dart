import 'package:flutter/foundation.dart';
import 'supabase_service.dart';
import 'rpc_client.dart';

class CrmConnectionService {
  final RpcClient _rpc;

  CrmConnectionService() : _rpc = SupabaseService.instance.rpc;

  /// #DATA: get_crm_connections
  /// RPC: get_crm_connections
  /// Inputs: none
  /// Output: List<Map<String, dynamic>>
  Future<List<Map<String, dynamic>>> getCrmConnections() async {
    try {
      debugPrint('📡 [RPC] Calling get_crm_connections');
      final response = await _rpc.callRpc('get_crm_connections');
      if (response == null) {
        throw Exception('get_crm_connections returned null');
      }
      final List<dynamic> connectionsList = response is List 
          ? response 
          : response is Map 
              ? [response] 
              : [];
      debugPrint('✅ [RPC] get_crm_connections success: ${connectionsList.length} connections');
      return connectionsList.map((json) => json as Map<String, dynamic>).toList();
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_crm_connections failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch CRM connections: $e');
    }
  }

  /// #DATA: is_crm_connected
  /// RPC: is_crm_connected
  /// Inputs: target_provider (text)
  /// Output: boolean
  Future<bool> isCrmConnected(String provider) async {
    try {
      debugPrint('📡 [RPC] Calling is_crm_connected with provider: $provider');
      final response = await _rpc.callRpc(
        'is_crm_connected',
        params: {'target_provider': provider},
      );
      if (response == null) {
        throw Exception('is_crm_connected returned null');
      }
      final isConnected = response as bool? ?? false;
      debugPrint('✅ [RPC] is_crm_connected success: $isConnected');
      return isConnected;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] is_crm_connected failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to check CRM connection: $e');
    }
  }

  /// #DATA: disconnect_crm
  /// RPC: disconnect_crm
  /// Inputs: target_provider (text)
  /// Output: Map<String, dynamic>
  Future<Map<String, dynamic>> disconnectCrm(String provider) async {
    try {
      debugPrint('📡 [RPC] Calling disconnect_crm with provider: $provider');
      final response = await _rpc.callRpc(
        'disconnect_crm',
        params: {'target_provider': provider},
      );
      if (response == null) {
        throw Exception('disconnect_crm returned null');
      }
      debugPrint('✅ [RPC] disconnect_crm success');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] disconnect_crm failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to disconnect CRM: $e');
    }
  }

  /// #DATA: get_crm_connection_by_provider
  /// RPC: get_crm_connection_by_provider
  /// Inputs: target_provider (text)
  /// Output: Map<String, dynamic>
  Future<Map<String, dynamic>> getCrmConnectionByProvider(String provider) async {
    try {
      debugPrint('📡 [RPC] Calling get_crm_connection_by_provider with provider: $provider');
      final response = await _rpc.callRpc(
        'get_crm_connection_by_provider',
        params: {'target_provider': provider},
      );
      if (response == null) {
        throw Exception('get_crm_connection_by_provider returned null');
      }
      debugPrint('✅ [RPC] get_crm_connection_by_provider success');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('❌ [RPC] get_crm_connection_by_provider failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch CRM connection: $e');
    }
  }
}
