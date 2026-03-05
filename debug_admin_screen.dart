// Add this temporary debug method to your _ScreenState class in admin_user_agent_management_screen.dart

// Temporary debug method - add this inside the _ScreenState class
Future<void> _debugUsersList() async {
  try {
    debugPrint('🔍 [DEBUG] Checking current user and users list...');
    
    // Call the debug RPC
    final response = await SupabaseService.instance.client.rpc('get_users_list');
    debugPrint('🔍 [DEBUG] RPC Response: $response');
    
    if (response is Map) {
      final debugInfo = response['debug'] as Map?;
      final allUsers = response['all_users'] as List?;
      final totalCount = response['total_count'];
      final activeCount = response['active_count'];
      
      debugPrint('🔍 [DEBUG] Current User: $debugInfo');
      debugPrint('🔍 [DEBUG] Total Users in DB: $totalCount');
      debugPrint('🔍 [DEBUG] Active Users: $activeCount');
      debugPrint('🔍 [DEBUG] Users Returned: ${allUsers?.length}');
      
      if (allUsers != null) {
        debugPrint('🔍 [DEBUG] All Users:');
        for (int i = 0; i < allUsers.length; i++) {
          final user = allUsers[i] as Map;
          debugPrint('  $i. ${user['name']} (${user['email']}) - ${user['role']} - Deleted: ${user['is_deleted']}');
        }
      }
    }
  } catch (e) {
    debugPrint('🔍 [DEBUG] Error: $e');
  }
}

// Then add this button to your admin screen temporarily
// In the _ContentArea widget, add this to the title row:
/*
Row(
  children: [
    Expanded(
      child: Text('User & Agent Management', ...),
    ),
    liveStatus,
    const SizedBox(width: 12),
    // Temporary debug button
    ElevatedButton(
      onPressed: _debugUsersList,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: const Text('Debug', style: TextStyle(fontSize: 12)),
    ),
    const SizedBox(width: 8),
    _OutlineButton(label: 'Filters'),
  ],
),
*/
