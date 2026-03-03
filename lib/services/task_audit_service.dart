import 'package:flutter/foundation.dart';
import '../models/task_audit_models.dart';
import '../models/agent_task_item.dart';
import 'supabase_service.dart';
import 'rpc_client.dart';

class TaskAuditService {
  final RpcClient _rpc;

  TaskAuditService() : _rpc = SupabaseService.instance.rpc;

  /// #DATA: get_task_audit_log_header
  /// RPC: get_task_audit_log_header
  /// Inputs: p_task_id (uuid)
  /// Output: TaskAuditHeader
  Future<TaskAuditHeader> getTaskAuditLogHeader(String taskId) async {
    try {
      debugPrint(
        '📡 [Task Audit] Calling get_task_audit_log_header for task: $taskId',
      );
      final response = await _rpc.callRpc(
        'get_task_audit_log_header',
        params: {'p_task_id': taskId},
      );

      if (response == null) {
        throw Exception('get_task_audit_log_header returned null');
      }

      return TaskAuditHeader.fromJson(Map<String, dynamic>.from(response));
    } catch (e, stackTrace) {
      debugPrint('❌ [Task Audit] get_task_audit_log_header failed: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }

  /// #DATA: get_task_audit_log_task_header
  /// RPC: get_task_audit_log_task_header
  /// Inputs: p_task_id (uuid)
  /// Output: TaskAuditTaskHeader
  Future<TaskAuditTaskHeader> getTaskAuditLogTaskHeader(String taskId) async {
    try {
      debugPrint(
        '📡 [Task Audit] Calling get_task_audit_log_task_header for task: $taskId',
      );
      final response = await _rpc.callRpc(
        'get_task_audit_log_task_header',
        params: {'p_task_id': taskId},
      );

      if (response == null) {
        throw Exception('get_task_audit_log_task_header returned null');
      }

      return TaskAuditTaskHeader.fromJson(Map<String, dynamic>.from(response));
    } catch (e, stackTrace) {
      debugPrint('❌ [Task Audit] get_task_audit_log_task_header failed: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }

  /// #DATA: get_task_activity_feed
  /// RPC: get_task_activity_feed
  /// Inputs: p_task_id (uuid)
  /// Output: List<TaskAuditEntry>
  ///
  /// Primary timeline feed for task activity UI
  Future<List<TaskAuditEntry>> getTaskActivityFeed(String taskId) async {
    try {
      debugPrint(
        '📡 [Task Audit] Calling get_task_activity_feed for task: $taskId',
      );

      final response = await _rpc.callRpc(
        'get_task_activity_feed',
        params: {'p_task_id': taskId},
      );

      if (response == null) {
        return [];
      }

      if (response is! List) {
        debugPrint(
          '⚠️ [Task Audit] Unexpected activity feed format: ${response.runtimeType}',
        );
        return [];
      }

      final entries = response
          .map((e) {
            try {
              return TaskAuditEntry.fromJson(Map<String, dynamic>.from(e));
            } catch (err) {
              debugPrint('❌ [Task Audit] Failed to parse activity entry: $err');
              return null;
            }
          })
          .whereType<TaskAuditEntry>()
          .toList();

      debugPrint('✅ [Task Audit] Parsed ${entries.length} activity feed items');
      return entries;
    } catch (e, stackTrace) {
      debugPrint('❌ [Task Audit] get_task_activity_feed failed: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }

  /// #DATA: get_agent_tasks
  /// RPC: get_agent_tasks
  /// Inputs: none (uses auth.uid())
  /// Output: List<AgentTaskItem>
  Future<List<AgentTaskItem>> getAgentTasks() async {
    try {
      debugPrint('📡 [Task Audit] Calling get_agent_tasks...');
      final response = await _rpc.callRpc('get_agent_tasks');

      if (response == null) {
        return [];
      }

      if (response is! List) {
        debugPrint(
          '⚠️ [Task Audit] Unexpected agent tasks format: ${response.runtimeType}',
        );
        return [];
      }

      final tasks = response
          .map((task) {
            try {
              return AgentTaskItem.fromJson(Map<String, dynamic>.from(task));
            } catch (e) {
              debugPrint('❌ [Task Audit] Error parsing agent task: $e');
              return null;
            }
          })
          .whereType<AgentTaskItem>()
          .toList();

      debugPrint('✅ [Task Audit] Parsed ${tasks.length} agent tasks');
      return tasks;
    } catch (e, stackTrace) {
      debugPrint('❌ [Task Audit] get_agent_tasks failed: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }
}
