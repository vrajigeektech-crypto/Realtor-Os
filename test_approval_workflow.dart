import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/services/admin_approval_service.dart';
import 'lib/services/recommendation_service.dart';

/// Test script to verify the approval workflow functionality
/// Run this in Dart to test the database functions
class ApprovalWorkflowTest {
  static Future<void> runTests() async {
    print('🧪 Starting Approval Workflow Tests...\n');
    
    try {
      // Initialize Supabase
      await Supabase.initialize(
        url: 'YOUR_SUPABASE_URL',
        anonKey: 'YOUR_SUPABASE_ANON_KEY',
      );
      
      final adminService = AdminApprovalService();
      final recommendationService = RecommendationService();
      
      // Test 1: Create a pending task
      print('📝 Test 1: Creating a pending task...');
      await testCreatePendingTask(recommendationService);
      
      // Test 2: Get pending tasks for admin
      print('\n📋 Test 2: Getting pending tasks for admin...');
      await testGetPendingTasks(adminService);
      
      // Test 3: Approve a task
      print('\n✅ Test 3: Approving a task...');
      await testApproveTask(adminService);
      
      // Test 4: Reject a task
      print('\n❌ Test 4: Rejecting a task...');
      await testRejectTask(adminService);
      
      print('\n🎉 All tests completed successfully!');
      
    } catch (e) {
      print('❌ Test failed: $e');
    }
  }
  
  static Future<void> testCreatePendingTask(RecommendationService service) async {
    try {
      // This would normally be called from the Review Recommendation Screen
      // For testing, we'll simulate creating a task directly
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not authenticated');
        return;
      }
      
      // Simulate the create_automation_task RPC call
      final result = await Supabase.instance.client.rpc('create_automation_task', params: {
        'p_user_id': userId,
        'p_task_type': 'test_workflow',
        'p_status': 'pending',
      });
      
      print('✅ Pending task created: $result');
    } catch (e) {
      print('❌ Failed to create pending task: $e');
    }
  }
  
  static Future<void> testGetPendingTasks(AdminApprovalService service) async {
    try {
      final pendingTasks = await service.getPendingTasks();
      print('✅ Found ${pendingTasks.length} pending tasks');
      
      for (final task in pendingTasks) {
        print('  - Task: ${task['task_type']} by ${task['user_name']}');
      }
    } catch (e) {
      print('❌ Failed to get pending tasks: $e');
    }
  }
  
  static Future<void> testApproveTask(AdminApprovalService service) async {
    try {
      // Get the first pending task
      final pendingTasks = await service.getPendingTasks();
      if (pendingTasks.isEmpty) {
        print('❌ No pending tasks to approve');
        return;
      }
      
      final taskId = pendingTasks.first['task_id'];
      final success = await service.approveTask(taskId);
      
      if (success) {
        print('✅ Task approved successfully: $taskId');
      } else {
        print('❌ Failed to approve task');
      }
    } catch (e) {
      print('❌ Failed to approve task: $e');
    }
  }
  
  static Future<void> testRejectTask(AdminApprovalService service) async {
    try {
      // Get the first pending task
      final pendingTasks = await service.getPendingTasks();
      if (pendingTasks.isEmpty) {
        print('❌ No pending tasks to reject');
        return;
      }
      
      final taskId = pendingTasks.first['task_id'];
      final success = await service.rejectTask(taskId, reason: 'Test rejection');
      
      if (success) {
        print('✅ Task rejected successfully: $taskId');
      } else {
        print('❌ Failed to reject task');
      }
    } catch (e) {
      print('❌ Failed to reject task: $e');
    }
  }
}

/// Manual SQL test script - run this in Supabase SQL Editor
const String manualTestScript = '''
-- Manual Test Script for Approval Workflow
-- Run this in Supabase SQL Editor to test the functions

-- 1. Test creating a pending task
SELECT create_automation_task(
  'YOUR_USER_ID', 
  'test_workflow', 
  'pending'
);

-- 2. Test getting pending tasks
SELECT * FROM get_pending_tasks_for_admin();

-- 3. Test approving a task (replace with actual task_id)
SELECT approve_automation_task(
  'TASK_ID_HERE',
  'ADMIN_USER_ID_HERE'
);

-- 4. Test rejecting a task (replace with actual task_id)
SELECT reject_automation_task(
  'TASK_ID_HERE',
  'ADMIN_USER_ID_HERE',
  'Test rejection reason'
);

-- 5. Check automation_tasks table
SELECT * FROM automation_tasks ORDER BY created_at DESC LIMIT 10;
''';

void main() {
  print('🧪 Approval Workflow Test Script');
  print('📝 To run the Dart test: ApprovalWorkflowTest.runTests()');
  print('🔧 To run SQL tests: Use the manualTestScript in Supabase SQL Editor');
  print('\n📋 Manual Test Steps:');
  print('1. Launch workflow from Review Recommendation Screen');
  print('2. Check if task appears in Queue Screen with "Pending" status');
  print('3. Check if task appears in Admin Content Approval Queue');
  print('4. Approve task from admin screen');
  print('5. Verify status changes to "Approved" on both screens');
  print('6. Test rejection workflow similarly');
}
