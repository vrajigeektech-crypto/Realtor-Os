import 'package:supabase_flutter/supabase_flutter.dart';

class AdminApprovalService {
  static final AdminApprovalService _instance = AdminApprovalService._internal();
  factory AdminApprovalService() => _instance;
  AdminApprovalService._internal();

  // Get all pending tasks for admin approval
  Future<List<Map<String, dynamic>>> getPendingTasks() async {
    try {
      final response = await Supabase.instance.client
          .rpc('get_pending_tasks_for_admin');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching pending tasks: $e');
      return [];
    }
  }

  // Get stream of all pending tasks for real-time admin approval
  Stream<List<Map<String, dynamic>>> getPendingTasksStream() {
    return Supabase.instance.client
        .from('automation_tasks')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .order('created_at', ascending: false);
  }

  // Approve a task
  Future<bool> approveTask(String taskId) async {
    try {
      final adminId = Supabase.instance.client.auth.currentUser?.id;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      final response = await Supabase.instance.client
          .rpc('approve_automation_task', params: {
        'p_task_id': taskId,
        'p_admin_user_id': adminId,
      });
      
      return response.isNotEmpty;
    } catch (e) {
      print('Error approving task: $e');
      return false;
    }
  }

  // Reject a task
  Future<bool> rejectTask(String taskId, {String? reason}) async {
    try {
      final adminId = Supabase.instance.client.auth.currentUser?.id;
      if (adminId == null) {
        throw Exception('Admin not authenticated');
      }

      final response = await Supabase.instance.client
          .rpc('reject_automation_task', params: {
        'p_task_id': taskId,
        'p_admin_user_id': adminId,
        'p_rejection_reason': reason ?? 'Rejected by admin',
      });
      
      return response.isNotEmpty;
    } catch (e) {
      print('Error rejecting task: $e');
      return false;
    }
  }

  // Get task details by ID
  Future<Map<String, dynamic>?> getTaskById(String taskId) async {
    try {
      final response = await Supabase.instance.client
          .from('automation_tasks')
          .select('*, auth.users(email, raw_user_meta_data)')
          .eq('id', taskId)
          .single();
      
      return response;
    } catch (e) {
      print('Error fetching task details: $e');
      return null;
    }
  }

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;
      
      final userData = user.userMetadata;
      if (userData == null) return false;
      return userData['role'] == 'admin' || userData['is_admin'] == true;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
}
