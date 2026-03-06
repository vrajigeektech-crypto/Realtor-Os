import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/admin_approval_service.dart';

class DebugAdminQueueScreen extends StatefulWidget {
  const DebugAdminQueueScreen({super.key});

  @override
  State<DebugAdminQueueScreen> createState() => _DebugAdminQueueScreenState();
}

class _DebugAdminQueueScreenState extends State<DebugAdminQueueScreen> {
  final AdminApprovalService _adminService = AdminApprovalService();
  List<Map<String, dynamic>> _pendingTasks = [];
  bool _isLoading = true;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _loadPendingTasks();
  }

  Future<void> _loadPendingTasks() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Loading pending tasks...';
    });

    try {
      // Test 1: Check if user is authenticated
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _debugInfo = '❌ User not authenticated';
          _isLoading = false;
        });
        return;
      }

      // Test 2: Try to call the RPC function
      final pendingTasks = await _adminService.getPendingTasks();
      
      setState(() {
        _pendingTasks = pendingTasks;
        _debugInfo = '✅ Successfully loaded ${pendingTasks.length} pending tasks';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _debugInfo = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestTask() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      // Create a test pending task directly
      final result = await Supabase.instance.client
          .from('automation_tasks')
          .insert({
            'user_id': user.id,
            'task_type': 'debug_test_task',
            'status': 'pending',
          })
          .select();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Test task created: ${result}')),
      );

      // Refresh the list
      _loadPendingTasks();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error creating test task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Admin Queue'),
        backgroundColor: const Color(0xFF1A1714),
        foregroundColor: const Color(0xFFD4C5B0),
      ),
      backgroundColor: const Color(0xFF1A1714),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Debug info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF201C19),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A2420)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Debug Info:',
                    style: TextStyle(
                      color: Color(0xFFB87333),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _debugInfo,
                    style: const TextStyle(
                      color: Color(0xFFD4C5B0),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                ElevatedButton(
                  onPressed: _loadPendingTasks,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB87333),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Refresh'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _createTestTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF70A870),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Test Task'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Loading indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFB87333)),
              )
            
            // Results
            else ...[
              Text(
                'Pending Tasks (${_pendingTasks.length}):',
                style: const TextStyle(
                  color: Color(0xFFD4C5B0),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _pendingTasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No pending tasks found.\nTry creating a test task.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF8A7D6E),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _pendingTasks.length,
                        itemBuilder: (context, index) {
                          final task = _pendingTasks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF201C19),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF2A2420)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task ID: ${task['task_id']}',
                                  style: const TextStyle(
                                    color: Color(0xFFB87333),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'User: ${task['user_name'] ?? task['user_email']}',
                                  style: const TextStyle(
                                    color: Color(0xFFD4C5B0),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Type: ${task['task_type']}',
                                  style: const TextStyle(
                                    color: Color(0xFF8A7D6E),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Status: ${task['status']}',
                                  style: const TextStyle(
                                    color: Color(0xFFB89060),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Created: ${task['created_at']}',
                                  style: const TextStyle(
                                    color: Color(0xFF8A7D6E),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
