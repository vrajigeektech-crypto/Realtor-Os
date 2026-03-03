import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

/// Import PostgresChange type
import 'package:supabase_flutter/supabase_flutter.dart' show PostgresChange;

class WalletDashboardService {
  static final SupabaseClient _client = SupabaseConfig.client;
  static StreamSubscription? _walletSubscription;
  static StreamSubscription? _transactionSubscription;

  /// Initialize service and ensure tables exist
  static Future<void> initialize() async {
    try {
      await _ensureTransactionsTable();
    } catch (e) {
      debugPrint('❌ [WalletService] Failed to initialize: $e');
    }
  }

  /// Ensure transactions table exists
  static Future<void> _ensureTransactionsTable() async {
    try {
      // Try to create transactions table if it doesn't exist
      await _client.rpc('create_transactions_table');
      
      // Also try to insert a test transaction to verify table exists
      // Skip test insertion as we don't want to use dummy data
    } catch (e) {
      // Table might already exist, which is fine
      debugPrint('ℹ️ [WalletService] Transactions table check: $e');
    }
  }

  /// Get or create user's wallet
  static Future<Map<String, dynamic>?> getOrCreateWallet() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // First try to get existing wallet
      final existingWallet = await _client
          .from('wallets')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingWallet != null) {
        return existingWallet;
      }

      // Create new wallet if doesn't exist
      final newWallet = await _client
          .from('wallets')
          .insert({
            'user_id': user.id,
          })
          .select()
          .single();

      return newWallet;
    } catch (e) {
      debugPrint('❌ [WalletService] Error getting wallet: $e');
      return null;
    }
  }

  /// Get wallet balance
  static Future<double?> getWalletBalance(String walletId) async {
    try {
      if (walletId.isEmpty) {
        debugPrint('⚠️ [WalletService] Wallet ID is empty');
        return 0.0;
      }
      
      final response = await _client.rpc('get_wallet_balance', params: {
        'p_wallet_id': walletId,
      });

      if (response == null) {
        debugPrint('⚠️ [WalletService] Balance response is null');
        return 0.0;
      }

      return response.toDouble();
    } catch (e) {
      debugPrint('❌ [WalletService] Error getting wallet balance: $e');
      return 0.0;
    }
  }

  /// Add transaction (credit or debit) - using token_ledger table
  static Future<Map<String, dynamic>?> addTransaction({
    required String walletId,
    required String type, // 'credit' or 'debit'
    required double amount,
    String? description,
    String? referenceId,
  }) async {
    try {
      debugPrint('🔄 [WalletService] Adding transaction: walletId=$walletId, type=$type, amount=$amount');
      
      // Insert transaction into token_ledger table
      final transaction = await _client
          .from('token_ledger')
          .insert({
            'wallet_id': walletId,
            'entry_type': type == 'credit' ? 'purchase' : 'spend', // Convert to DB schema types
            'amount': amount.round(),
            'description': description,
            'reference_id': referenceId,
          })
          .select()
          .single();
      
      debugPrint('✅ [WalletService] Transaction added successfully: ${transaction['id']}');
      
      return {
        'success': true,
        'transaction_id': transaction['id'],
        'type': type,
        'amount': amount,
        'description': description,
        'reference_id': referenceId,
      };
    } catch (e) {
      debugPrint('❌ [WalletService] Error adding transaction: $e');
      return null;
    }
  }

  /// Add tokens to user wallet
  static Future<bool> addTokens(int tokenAmount) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ [WalletService] No authenticated user found');
        return false;
      }

      // Get user's wallet
      final walletData = await _client
          .from('wallets')
          .select('id')
          .eq('user_id', user.id)
          .single();

      final walletId = walletData['id'];

      // Add credit transaction for tokens
      final result = await addTransaction(
        walletId: walletId,
        type: 'credit',
        amount: tokenAmount.toDouble(),
        description: 'Token purchase via Stripe',
        referenceId: 'stripe_purchase_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result != null) {
        debugPrint('✅ [WalletService] Successfully added $tokenAmount tokens');
        return true;
      } else {
        debugPrint('❌ [WalletService] Failed to add tokens');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [WalletService] Error adding tokens: $e');
      return false;
    }
  }

  /// Get transaction history - using token_ledger table
  static Future<List<Map<String, dynamic>>> getTransactionHistory({
    required String walletId,
    int limit = 20,
  }) async {
    try {
      debugPrint('📡 [WalletService] Getting transaction history from token_ledger for wallet: $walletId');
      final response = await _client
          .from('token_ledger')
          .select()
          .eq('wallet_id', walletId)
          .order('created_at', ascending: false)
          .limit(limit);
      
      final List<dynamic> transactionsList = response is List
          ? response
          : response is Map
          ? [response]
          : [];
      
      debugPrint('✅ [WalletService] Retrieved ${transactionsList.length} transactions from token_ledger');
      return transactionsList
          .map((json) => {
          'id': json['id']?.toString() ?? '',
          'type': json['entry_type'] == 'purchase' ? 'credit' : (json['entry_type'] == 'spend' ? 'debit' : json['entry_type']?.toString() ?? ''), // Convert DB types to app types
          'amount': (json['amount'] as num?)?.toDouble() ?? 0.0,
          'description': json['description']?.toString() ?? '',
          'source': json['source']?.toString() ?? '',
          'reference_id': json['reference_id']?.toString() ?? '',
          'created_at': json['created_at']?.toString() ?? '',
        })
          .toList();
    } catch (e) {
      debugPrint('❌ [WalletService] Failed to fetch transaction history: $e');
      throw Exception('Failed to fetch transaction history: $e');
    }
  }

  /// Listen to wallet changes in real-time
  static Stream<Map<String, dynamic>> watchWallet(String walletId) {
    return _client
        .from('wallets')
        .stream(primaryKey: ['id'])
        .eq('id', walletId)
        .map((data) => data.isNotEmpty ? data.first : <String, dynamic>{});
  }

  /// Listen to transaction changes in real-time - using token_ledger
  static Stream<List<Map<String, dynamic>>> watchTransactions(String walletId) {
    return _client
        .from('token_ledger')
        .stream(primaryKey: ['id'])
        .eq('wallet_id', walletId)
        .order('created_at', ascending: false)
        .map((data) {
          return data.map((record) {
            return {
              'id': record['id']?.toString() ?? '',
              'type': record['entry_type'] == 'purchase' ? 'credit' : (record['entry_type'] == 'spend' ? 'debit' : record['entry_type']?.toString() ?? ''), // Convert DB types to app types
              'amount': (record['amount'] as num?)?.toDouble() ?? 0.0,
              'description': record['description']?.toString() ?? '',
              'source': record['source']?.toString() ?? '',
              'reference_id': record['reference_id']?.toString() ?? '',
              'created_at': record['created_at']?.toString() ?? '',
            };
          }).toList();
        });
  }

  /// Start real-time subscriptions
  static void startRealtimeUpdates({
    required String walletId,
    Function(Map<String, dynamic>)? onWalletUpdate,
    Function(List<Map<String, dynamic>>)? onTransactionUpdate,
  }) {
    // Cancel existing subscriptions
    stopRealtimeUpdates();

    // Subscribe to wallet changes
    if (onWalletUpdate != null) {
      _walletSubscription = watchWallet(walletId).listen(onWalletUpdate);
    }

    // Subscribe to transaction changes
    if (onTransactionUpdate != null) {
      _transactionSubscription = watchTransactions(walletId).listen(onTransactionUpdate);
    }
  }

  /// Stop real-time subscriptions
  static void stopRealtimeUpdates() {
    _walletSubscription?.cancel();
    _transactionSubscription?.cancel();
    _walletSubscription = null;
    _transactionSubscription = null;
  }

  /// Credit tokens to wallet (for purchases)
  static Future<bool> creditTokens({
    required String walletId,
    required int tokenAmount,
    String? referenceId,
  }) async {
    final result = await addTransaction(
      walletId: walletId,
      type: 'credit',
      amount: tokenAmount.toDouble(),
      description: 'Purchased $tokenAmount tokens',
      referenceId: referenceId,
    );

    return result?['success'] == true;
  }

  /// Debit tokens from wallet (for spending)
  static Future<bool> debitTokens({
    required String walletId,
    required int tokenAmount,
    String? description,
  }) async {
    final result = await addTransaction(
      walletId: walletId,
      type: 'debit',
      amount: tokenAmount.toDouble(),
      description: description ?? 'Spent $tokenAmount tokens',
    );

    return result?['success'] == true;
  }

  /// Get formatted transaction description
  static String getTransactionDescription(Map<String, dynamic> transaction) {
    final description = transaction['description'] as String?;
    final type = transaction['type'] as String;
    final amount = transaction['amount'] as double;

    if (description != null && description.isNotEmpty) {
      return description;
    }

    return type == 'credit' 
        ? 'Received ${amount.toInt()} tokens'
        : 'Spent ${amount.toInt()} tokens';
  }

  /// Format transaction amount with sign
  static String formatTransactionAmount(Map<String, dynamic> transaction) {
    final type = transaction['type'] as String;
    final amount = transaction['amount'] as double;
    final sign = type == 'credit' ? '+' : '-';

    return '$sign${amount.toInt()} tokens';
  }

  /// Get transaction color based on type
  static String getTransactionColor(String type) {
    return type == 'credit' ? 'green' : 'red';
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
