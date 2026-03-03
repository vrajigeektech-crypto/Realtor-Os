import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/task_overview.dart';
import '../models/task_detail.dart';
import 'supabase_service.dart';
import 'rpc_client.dart';

/// Service class for managing tasks
/// All data access goes through RPC calls
class TaskService {
  final RpcClient _rpc;

  TaskService() : _rpc = SupabaseService.instance.rpc;

  /// #DATA: get_task_queue_table
  /// RPC: get_task_queue_table
  /// Inputs: none
  /// Output: List<Task>
  Future<List<Task>> getTasks() async {
    try {
      final response = await _rpc.getTaskQueueTable();
      return response.map((json) => Task.fromRpcJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  /// #DATA: get_task_overview_counts
  /// RPC: get_task_overview_counts
  /// Inputs: none
  /// Output: TaskOverview
  Future<TaskOverview> getTaskOverview() async {
    try {
      final response = await _rpc.getTaskOverviewCounts();
      return TaskOverview.fromRpcJson(response);
    } catch (e) {
      throw Exception('Failed to fetch task overview: $e');
    }
  }

  /// #DATA: view_task_detail
  /// RPC: view_task_detail
  /// Inputs: p_task_id (uuid)
  /// Output: TaskDetail
  Future<TaskDetail> getTaskDetail(String taskId) async {
    try {
      debugPrint('🔍 [TaskService] Fetching task detail for ID: $taskId');
      final response = await _rpc.viewTaskDetail(taskId);
      debugPrint('✅ [TaskService] Task detail response received: $response');
      return TaskDetail.fromRpcJson(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [TaskService] Failed to fetch task detail: $e');
      debugPrint('   Stack: $stackTrace');
      throw Exception('Failed to fetch task detail: $e');
    }
  }
}
