import 'package:flutter/foundation.dart';
import '../models/content_queue_item_model.dart';
import 'supabase_service.dart';

class ApprovalQueueService {
  final _supabase = SupabaseService.instance.client;

  /// Fetch content approval queue from RPC
  /// Returns: List<ContentQueueItemModel>
  Future<List<ContentQueueItemModel>> fetchQueue() async {
    try {
      debugPrint('📡 [Approval Queue] Calling get_content_approval_queue RPC...');
      
      final response = await _supabase.rpc('get_content_approval_queue');
      
      if (response == null) {
        debugPrint('⚠️ [Approval Queue] RPC returned null');
        return [];
      }

      debugPrint('✅ [Approval Queue] RPC success, parsing response...');
      
      List<dynamic> items;
      if (response is List) {
        items = response;
      } else if (response is Map && response.containsKey('items')) {
        items = response['items'] as List<dynamic>? ?? [];
      } else {
        debugPrint('⚠️ [Approval Queue] Unexpected response format: ${response.runtimeType}');
        return [];
      }

      final queueItems = items
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return ContentQueueItemModel.fromJson(item);
              } else if (item is Map) {
                return ContentQueueItemModel.fromJson(Map<String, dynamic>.from(item));
              }
              return null;
            } catch (e) {
              debugPrint('❌ [Approval Queue] Error parsing item: $e');
              return null;
            }
          })
          .whereType<ContentQueueItemModel>()
          .toList();

      debugPrint('✅ [Approval Queue] Parsed ${queueItems.length} items');
      return queueItems;
    } catch (e, stackTrace) {
      debugPrint('❌ [Approval Queue] Failed to fetch queue: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }

  /// Send reminder email via Edge Function
  /// Returns: Map with success, approval_id, client_email, reminder_count
  Future<Map<String, dynamic>> sendReminderEmail(String approvalId) async {
    try {
      debugPrint('📧 [Approval Queue] Sending reminder email for approval: $approvalId');
      
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated. Please log in first.');
      }

      final accessToken = session.accessToken;
      if (accessToken.isEmpty) {
        throw Exception('Invalid session: access token is missing.');
      }

      final response = await _supabase.functions.invoke(
        'send-approval-reminder-email',
        body: {
          'p_approval_id': approvalId,
        },
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('📧 [Approval Queue] Edge Function response status: ${response.status}');
      debugPrint('📧 [Approval Queue] Edge Function response data: ${response.data}');

      if (response.status == 401) {
        throw Exception('Session expired. Please log in again.');
      }

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error'] as String? ??
            errorData?['message'] as String? ??
            'Failed to send reminder email';
        throw Exception(errorMessage);
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('No response data from server');
      }

      final success = data['success'] as bool? ?? false;
      if (!success) {
        final errorMessage = data['error'] as String? ?? 'Failed to send reminder email';
        throw Exception(errorMessage);
      }

      debugPrint('✅ [Approval Queue] Reminder email sent successfully');
      return data;
    } catch (e, stackTrace) {
      debugPrint('❌ [Approval Queue] Failed to send reminder email: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }
}
