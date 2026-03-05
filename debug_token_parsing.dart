// Add this debug method to your admin screen to see what data is being received

// Add this inside _ScreenState class in admin_user_agent_management_screen.dart

Future<void> _debugTokenParsing() async {
  try {
    debugPrint('🔍 [DEBUG] Starting token parsing debug...');
    
    // Call RPC directly to see raw response
    final response = await SupabaseService.instance.client.rpc('get_users_list');
    debugPrint('🔍 [DEBUG] Raw RPC Response: $response');
    
    if (response is List) {
      debugPrint('🔍 [DEBUG] Response is List with ${response.length} items');
      
      for (int i = 0; i < response.length; i++) {
        final userJson = response[i] as Map<String, dynamic>;
        debugPrint('🔍 [DEBUG] User $i: $userJson');
        
        final tokenBalance = userJson['token_balance'];
        debugPrint('🔍 [DEBUG] Token Balance Type: ${tokenBalance.runtimeType}');
        debugPrint('🔍 [DEBUG] Token Balance Value: $tokenBalance');
        
        // Try parsing like UserListItem does
        final parsedBalance = (tokenBalance is num 
                            ? tokenBalance.toInt() 
                            : (tokenBalance as String? ?? '').isNotEmpty 
                              ? int.tryParse(tokenBalance as String) ?? 0
                              : (tokenBalance as int? ?? 0));
        
        debugPrint('🔍 [DEBUG] Parsed Balance: $parsedBalance');
      }
    } else {
      debugPrint('🔍 [DEBUG] Response is not a List: ${response.runtimeType}');
    }
  } catch (e) {
    debugPrint('🔍 [DEBUG] Debug error: $e');
  }
}

// Then add this debug button to your admin screen temporarily
// In the _ContentArea title row, add:
/*
ElevatedButton(
  onPressed: _debugTokenParsing,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
  child: const Text('Debug Tokens', style: TextStyle(fontSize: 12)),
),
*/
