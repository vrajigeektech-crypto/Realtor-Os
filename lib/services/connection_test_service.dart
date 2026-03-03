import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to test Supabase connection and diagnose issues
class ConnectionTestService {
  static Future<Map<String, dynamic>> testConnection() async {
    final results = <String, dynamic>{};
    
    try {
      // Test 1: Basic Supabase connection
      final client = Supabase.instance.client;
      results['supabase_initialized'] = true;
      results['supabase_url'] = 'https://macenrukodfgfeowrqqf.supabase.co'; // From config
      
      // Test 2: Auth state
      final currentUser = client.auth.currentUser;
      final session = client.auth.currentSession;
      
      results['user_authenticated'] = currentUser != null;
      results['user_email'] = currentUser?.email;
      results['user_id'] = currentUser?.id;
      results['session_exists'] = session != null;
      
      if (currentUser == null) {
        results['error'] = 'User not authenticated';
        return results;
      }
      
      // Test 3: Simple table query (wallets)
      try {
        final walletQuery = await client
            .from('wallets')
            .select('id, user_id')
            .eq('user_id', currentUser!.id);
        
        results['wallet_query_success'] = true;
        results['wallet_count'] = (walletQuery as List).length;
        results['wallet_data'] = walletQuery;
      } catch (e) {
        results['wallet_query_success'] = false;
        results['wallet_query_error'] = e.toString();
      }
      
      // Test 4: Try to create wallet if none exists
      final walletCount = results['wallet_count'] as int? ?? 0;
      if (walletCount == 0) {
        try {
          final walletInsert = await client
              .from('wallets')
              .insert({'user_id': currentUser!.id})
              .select('id, user_id')
              .single();
          
          results['wallet_creation_success'] = true;
          results['created_wallet'] = walletInsert;
        } catch (e) {
          results['wallet_creation_success'] = false;
          results['wallet_creation_error'] = e.toString();
        }
      }
      
      // Test 5: Test token_ledger query
      final walletCreationSuccess = results['wallet_creation_success'] as bool? ?? false;
      if (walletCount > 0 || walletCreationSuccess) {
        try {
          final walletId = results['wallet_count'] > 0 
              ? (results['wallet_data'] as List).first['id']
              : results['created_wallet']['id'];
              
          final ledgerQuery = await client
              .from('token_ledger')
              .select('entry_type, amount, source, created_at')
              .eq('wallet_id', walletId);
          
          results['ledger_query_success'] = true;
          results['ledger_count'] = (ledgerQuery as List).length;
          results['ledger_data'] = ledgerQuery;
        } catch (e) {
          results['ledger_query_success'] = false;
          results['ledger_query_error'] = e.toString();
        }
      }
      
    } catch (e) {
      results['supabase_initialized'] = false;
      results['initialization_error'] = e.toString();
    }
    
    return results;
  }
  
  static void logResults(Map<String, dynamic> results) {
    debugPrint('🔍 === SUPABASE CONNECTION TEST RESULTS ===');
    
    if (results['supabase_initialized'] == true) {
      debugPrint('✅ Supabase initialized');
      debugPrint('📡 URL: ${results['supabase_url']}');
      
      if (results['user_authenticated'] == true) {
        debugPrint('✅ User authenticated');
        debugPrint('👤 Email: ${results['user_email']}');
        debugPrint('🆔 ID: ${results['user_id']}');
        
        if (results['wallet_query_success'] == true) {
          debugPrint('✅ Wallet query successful');
          debugPrint('💼 Wallet count: ${results['wallet_count']}');
          
          if (results['wallet_creation_success'] == true) {
            debugPrint('✅ Wallet created successfully');
            debugPrint('🆕 New wallet: ${results['created_wallet']}');
          }
          
          if (results['ledger_query_success'] == true) {
            debugPrint('✅ Ledger query successful');
            debugPrint('📊 Ledger entries: ${results['ledger_count']}');
          } else {
            debugPrint('❌ Ledger query failed: ${results['ledger_query_error']}');
          }
        } else {
          debugPrint('❌ Wallet query failed: ${results['wallet_query_error']}');
          
          if (results['wallet_creation_success'] == false) {
            debugPrint('❌ Wallet creation failed: ${results['wallet_creation_error']}');
          }
        }
      } else {
        debugPrint('❌ User not authenticated: ${results['error']}');
      }
    } else {
      debugPrint('❌ Supabase initialization failed: ${results['initialization_error']}');
    }
    
    debugPrint('🔍 === END TEST RESULTS ===');
  }
}
