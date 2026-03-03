// lib/services/agent_wallet_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgentWalletService {
  AgentWalletService._();
  static final AgentWalletService instance = AgentWalletService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// ===============================
  /// GET WALLET BALANCE
  /// RPC: get_wallet_balance(p_wallet_id)
  /// ===============================
  Future<int> getWalletBalance({required String walletId}) async {
    debugPrint('📡 [WalletService] getWalletBalance START');
    debugPrint('🪪 walletId: $walletId');

    final res = await _supabase.rpc(
      'get_wallet_balance',
      params: {'p_wallet_id': walletId},
    );

    debugPrint('✅ [WalletService] getWalletBalance raw: $res');

    if (res == null) return 0;
    if (res is int) return res;
    if (res is num) return res.toInt();

    return 0;
  }

  /// ===============================
  /// GET WALLET LEDGER
  /// RPC: get_wallet_transactions_extended(p_wallet_id, p_time_filter)
  /// ===============================
  Future<List<Map<String, dynamic>>> getWalletLedger({
    required String walletId,
    String timeFilter = 'ALL',
  }) async {
    debugPrint('📡 [WalletService] getWalletLedger START');
    debugPrint('🪪 walletId: $walletId');
    debugPrint('⏱ filter: $timeFilter');

    final res = await _supabase.rpc(
      'get_wallet_transactions_extended',
      params: {'p_wallet_id': walletId, 'p_time_filter': timeFilter},
    );

    debugPrint('✅ [WalletService] getWalletLedger raw: $res');

    if (res == null) return [];
    if (res is List) {
      return res.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  }
}
