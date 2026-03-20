import 'package:flutter/foundation.dart';
import 'supabase_service.dart';
import 'rpc_client.dart';

class CrmConnectionService {
  final RpcClient _rpc;
  final _supabase = SupabaseService.instance.client;

  CrmConnectionService() : _rpc = SupabaseService.instance.rpc;

  bool _isMissingRpcFunctionError(Object e) {
    final message = e.toString();
    return message.contains('PGRST202') ||
        message.contains('Could not find the function public.');
  }

  bool _isMissingTableError(Object e) {
    final message = e.toString();
    return message.contains('PGRST205') ||
        message.contains("Could not find the table 'public.user_crm_connections'");
  }

  List<String> _providerAliases(String provider) {
    final normalized = provider.toLowerCase();
    if (normalized == 'followupboss' || normalized == 'follow_up_boss') {
      return const ['followupboss', 'follow_up_boss'];
    }
    return [normalized];
  }

  String _normalizeProvider(String provider) {
    final normalized = provider.toLowerCase();
    if (normalized == 'follow_up_boss') {
      return 'followupboss';
    }
    return normalized;
  }

  Future<List<Map<String, dynamic>>> _getCrmConnectionsFallback() async {
    debugPrint('⚠️ [CRM] Falling back to direct table query for connections');
    final rows = await _supabase
        .from('user_crm_connections')
        .select('provider, access_token, refresh_token, expires_at, metadata');

    final rawList = rows as List<dynamic>? ?? const [];
    return rawList.map((item) {
      final row = item as Map<String, dynamic>;
      final provider = _normalizeProvider((row['provider'] as String?) ?? '');
      final accessToken = (row['access_token'] as String?) ?? '';
      final refreshToken = (row['refresh_token'] as String?) ?? '';
      final isConnected = accessToken.isNotEmpty || refreshToken.isNotEmpty;
      return {
        ...row,
        'provider': provider,
        'is_connected': isConnected,
      };
    }).toList();
  }

  Future<Map<String, dynamic>> _getCrmConnectionByProviderFallback(
    String provider,
  ) async {
    debugPrint(
      '⚠️ [CRM] Falling back to direct table query for provider: $provider',
    );
    final aliases = _providerAliases(provider);
    final orFilter = aliases.map((p) => 'provider.eq.$p').join(',');
    final row = await _supabase
        .from('user_crm_connections')
        .select('provider, access_token, refresh_token, expires_at, metadata')
        .or(orFilter)
        .maybeSingle();

    if (row == null) {
      return {};
    }

    final rowMap = row;
    final accessToken = (rowMap['access_token'] as String?) ?? '';
    final refreshToken = (rowMap['refresh_token'] as String?) ?? '';
    return {
      ...rowMap,
      'provider': _normalizeProvider((rowMap['provider'] as String?) ?? ''),
      'is_connected': accessToken.isNotEmpty || refreshToken.isNotEmpty,
    };
  }

  /// #DATA: get_crm_connections
  /// RPC: get_crm_connections
  /// Inputs: none
  /// Output: `List<Map<String, dynamic>>`
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
      if (_isMissingRpcFunctionError(e)) {
        try {
          return await _getCrmConnectionsFallback();
        } catch (fallbackError, fallbackStackTrace) {
          if (_isMissingTableError(fallbackError)) {
            debugPrint(
              '⚠️ [CRM] No CRM table found yet; returning empty connections list',
            );
            return [];
          }
          debugPrint('❌ [CRM] Fallback get connections failed: $fallbackError');
          debugPrint('   Stack: $fallbackStackTrace');
          throw Exception('Failed to fetch CRM connections: $fallbackError');
        }
      }
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
      if (_isMissingRpcFunctionError(e)) {
        try {
          final conn = await _getCrmConnectionByProviderFallback(provider);
          return conn['is_connected'] as bool? ?? false;
        } catch (fallbackError, fallbackStackTrace) {
          if (_isMissingTableError(fallbackError)) {
            debugPrint(
              '⚠️ [CRM] No CRM table found yet; treating provider as disconnected',
            );
            return false;
          }
          debugPrint('❌ [CRM] Fallback is connected failed: $fallbackError');
          debugPrint('   Stack: $fallbackStackTrace');
          throw Exception('Failed to check CRM connection: $fallbackError');
        }
      }
      debugPrint('❌ [RPC] is_crm_connected failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to check CRM connection: $e');
    }
  }

  /// #DATA: disconnect_crm
  /// RPC: disconnect_crm
  /// Inputs: target_provider (text)
  /// Output: `Map<String, dynamic>`
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
      if (_isMissingRpcFunctionError(e)) {
        try {
          final aliases = _providerAliases(provider);
          await _supabase
              .from('user_crm_connections')
              .delete()
              .or(aliases.map((p) => 'provider.eq.$p').join(','));
          return {
            'success': true,
            'provider': _normalizeProvider(provider),
          };
        } catch (fallbackError, fallbackStackTrace) {
          if (_isMissingTableError(fallbackError)) {
            debugPrint(
              '⚠️ [CRM] No CRM table found yet; disconnect treated as no-op',
            );
            return {
              'success': true,
              'provider': _normalizeProvider(provider),
              'noop': true,
            };
          }
          debugPrint('❌ [CRM] Fallback disconnect failed: $fallbackError');
          debugPrint('   Stack: $fallbackStackTrace');
          throw Exception('Failed to disconnect CRM: $fallbackError');
        }
      }
      debugPrint('❌ [RPC] disconnect_crm failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to disconnect CRM: $e');
    }
  }

  /// #DATA: get_crm_connection_by_provider
  /// RPC: get_crm_connection_by_provider
  /// Inputs: target_provider (text)
  /// Output: `Map<String, dynamic>`
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
      if (_isMissingRpcFunctionError(e)) {
        try {
          return await _getCrmConnectionByProviderFallback(provider);
        } catch (fallbackError, fallbackStackTrace) {
          if (_isMissingTableError(fallbackError)) {
            debugPrint(
              '⚠️ [CRM] No CRM table found yet; returning empty provider connection',
            );
            return {};
          }
          debugPrint('❌ [CRM] Fallback provider query failed: $fallbackError');
          debugPrint('   Stack: $fallbackStackTrace');
          throw Exception('Failed to fetch CRM connection: $fallbackError');
        }
      }
      debugPrint('❌ [RPC] get_crm_connection_by_provider failed: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch CRM connection: $e');
    }
  }
}
