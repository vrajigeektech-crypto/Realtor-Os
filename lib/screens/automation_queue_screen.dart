import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../layout/main_layout.dart';
import '../core/app_colors.dart';
import '../services/recommendation_service.dart';
import '../utils/app_styles.dart';
import '../models/recommendation_models.dart';

class AutomationQueueScreen extends StatefulWidget {
  const AutomationQueueScreen({super.key});

  @override
  State<AutomationQueueScreen> createState() => _AutomationQueueScreenState();
}

class _AutomationQueueScreenState extends State<AutomationQueueScreen> {
  final RecommendationService _recommendationService = RecommendationService();
  List<QueueItem> _queueItems = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  StreamSubscription? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _loadQueueItems();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    
    // Listen for changes to this user's automation tasks
    _realtimeSubscription = Supabase.instance.client
        .from('automation_tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((_) {
          _loadQueueItems(); // Refresh when any of this user's tasks change
        });
  }

  Future<void> _loadQueueItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final queueItems = await _recommendationService.getAutomationQueue(userId);
      
      print('=== QUEUE ITEMS DEBUG ===');
      for (var item in queueItems) {
        print('Title: ${item.promotionTitle}, Tokens: ${item.tokensDeducted}, Status: ${item.status}');
      }
      print('========================');
      
      setState(() {
        _queueItems = queueItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error silently for now
    }
  }

  List<QueueItem> get _filteredItems {
    if (_selectedStatus == 'all') return _queueItems;
    return _queueItems.where((item) => item.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      activeIndex: 11,
      title: 'Automation Queue',
      child: Container(
        decoration: AppStyles.fidelityBackgroundDecoration(),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMainContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Automation Queue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'OST Balance: 8021.00',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'VA Assignments: 3',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A373).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'VA Assignments: Operational',
                      style: TextStyle(
                        color: Color(0xFFD4A373),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _loadQueueItems,
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year} • ${hour.toString().padLeft(2, '0')}:$minute $ampm';
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'scheduled':
        return 'Scheduled';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.amber; // Amber for pending
      case 'approved':
        return Colors.green; // Green for approved
      case 'scheduled':
        return Colors.blue; // Blue for scheduled
      case 'processing':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'rejected':
        return Colors.red.shade700; // Darker red for rejected
      default:
        return Colors.amber; // Default to amber for pending
    }
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = _filteredItems;

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No automation tasks found.',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQueueItems,
      child: ListView.separated(
        padding: const EdgeInsets.all(40),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildQueueItemCard(
            title: item.promotionTitle,
            status: _formatStatus(item.status),
            queuedTime: _formatDate(item.queuedAt),
            tokens: item.tokensDeducted,
            statusColor: _statusColor(item.status),
            rejectionReason: item.rejectionReason,
          );
        },
      ),
    );
  }

  Widget _buildQueueItemCard({
    required String title,
    required String status,
    required String queuedTime,
    required int tokens,
    Color statusColor = Colors.blue,
    String? rejectionReason,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A3436)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '-$tokens tokens',
                  style: const TextStyle(
                    color: AppColors.roseGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Queued: $queuedTime',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            if (status.toLowerCase() == 'rejected' &&
                rejectionReason != null &&
                rejectionReason.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin comment',
                      style: TextStyle(
                        color: Colors.red.shade200,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rejectionReason,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
