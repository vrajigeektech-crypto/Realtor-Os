import 'package:flutter/foundation.dart';
import 'lib/services/supabase_service.dart';
import 'lib/services/rpc_client.dart';

void main() async {
  debugPrint('🔍 Testing Supabase connection...');
  
  try {
    final rpc = SupabaseService.instance.rpc;
    
    // Test 1: Simple connection test
    debugPrint('📡 Testing simple connection...');
    final response = await rpc.callRpc('get_all_wallets_for_user_bypass', params: {'p_user_id': 'test'});
    debugPrint('✅ Connection test response: $response');
    
    // Test 2: Test with actual user ID (you'll need to replace this)
    const userId = 'your-actual-user-id-here';
    debugPrint('📡 Testing with user ID: $userId');
    final userResponse = await rpc.callRpc('get_all_wallets_for_user_bypass', params: {'p_user_id': userId});
    debugPrint('✅ User test response: $userResponse');
    
  } catch (e, stackTrace) {
    debugPrint('❌ Connection test failed: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}
