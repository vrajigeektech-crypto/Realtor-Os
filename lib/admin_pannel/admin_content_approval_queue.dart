import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/admin_approval_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────
enum ContentStatus { pending, approved, rejected, flagged }
enum ContentTab { image, video, audio, writing }

class ContentItem {
  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final ContentStatus status;
  final ContentTab type;
  final IconData previewIcon;
  final String userId;
  final String userEmail;
  final String userName;
  final String taskType;
  final List<String> imageUrls;

  String? get primaryImageUrl =>
      imageUrls.isNotEmpty ? imageUrls.first : null;

  const ContentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.status,
    required this.type,
    required this.previewIcon,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.taskType,
    required this.imageUrls,
  });
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class AdminContentApprovalQueueScreen extends StatefulWidget {
  const AdminContentApprovalQueueScreen({super.key});

  @override
  State<AdminContentApprovalQueueScreen> createState() => _AdminContentApprovalQueueScreenState();
}

class _AdminContentApprovalQueueScreenState extends State<AdminContentApprovalQueueScreen>
    with SingleTickerProviderStateMixin {
  ContentTab _selectedTab = ContentTab.image;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;
  
  final AdminApprovalService _adminService = AdminApprovalService();
  List<ContentItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _pendingCount = 0;
  ContentItem? _selectedItem;
  int _selectedImageIndex = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _loadPendingTasks();
    _setupRealtimeSubscription();
  }

  StreamSubscription? _realtimeSubscription;

  void _setupRealtimeSubscription() {
    // Listen for all changes to automation_tasks table
    // We need to listen for all status changes (pending -> queued/rejected)
    _realtimeSubscription = Supabase.instance.client
        .from('automation_tasks')
        .stream(primaryKey: ['id'])
        .listen((_) {
          _loadPendingTasks(); // Refresh the pending tasks list
        });
  }

  Future<void> _loadPendingTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pendingTasks = await _adminService.getPendingTasks();

      // Fetch per-task images directly from automation_tasks so preview works
      // even if the RPC doesn't return image_urls yet.
      final pendingTaskIds = <String>[
        for (final t in pendingTasks)
          if (t['task_id'] != null) t['task_id'].toString(),
      ];
      final Map<String, List<String>> imagesByTaskId = {};
      if (pendingTaskIds.isNotEmpty) {
        try {
          final rows = await Supabase.instance.client
              .from('automation_tasks')
              .select('id, image_urls')
              .inFilter('id', pendingTaskIds);

          for (final r in rows) {
            final id = (r['id'] ?? '').toString();
            if (id.isEmpty) continue;
            final urls = (r['image_urls'] is List)
                ? List<String>.from(r['image_urls'] as List)
                : const <String>[];
            imagesByTaskId[id] = urls;
          }
        } catch (e) {
          // If the column doesn't exist yet, just skip without spamming logs.
          final msg = e.toString();
          if (!msg.contains('image_urls') ||
              !msg.contains('does not exist')) {
            debugPrint('[AdminApproval] Failed to load task image_urls: $e');
          }
        }
      }

      // Fetch gallery images for each unique user so we can show
      // Supabase Storage-backed previews in the approval queue.
      final userIds = <String>{
        for (final task in pendingTasks)
          if (task['user_id'] != null) '${task['user_id']}',
      };

      final Map<String, List<String>> galleryByUser = {};
      final supabase = Supabase.instance.client;

      for (final userId in userIds) {
        try {
          final response = await supabase
              .from('users')
              .select('gallery_urls')
              .eq('id', userId)
              .maybeSingle();

          if (response != null &&
              response['gallery_urls'] != null &&
              response['gallery_urls'] is List) {
            galleryByUser[userId] =
                List<String>.from(response['gallery_urls'] as List);
          } else {
            galleryByUser[userId] = const [];
          }
        } catch (_) {
          galleryByUser[userId] = const [];
        }
      }

      final contentItems = pendingTasks.map((task) {
        // Map task data to ContentItem
        final taskType = task['task_type'] as String? ?? 'unknown';
        final title = task['user_name'] ?? task['user_email'] ?? 'Anonymous';
        final subtitle = _getTaskTitle(taskType);
        final timeAgo = _formatTimeAgo(task['created_at']);
        final icon = _getTaskIcon(taskType);
        final userId = '${task['user_id']}';
        final taskId = task['task_id'].toString();
        final taskImages = imagesByTaskId[taskId] ??
            ((task['image_urls'] is List)
                ? List<String>.from(task['image_urls'] as List)
                : const <String>[]);
        final images = taskImages.isNotEmpty ? taskImages
            : (galleryByUser[userId] ?? const <String>[]);

        return ContentItem(
          id: task['task_id'],
          title: title,
          subtitle: subtitle,
          timeAgo: timeAgo,
          status: ContentStatus.pending,
          type: _getContentType(taskType),
          previewIcon: icon,
          userId: userId,
          userEmail: task['user_email'] ?? '',
          userName: task['user_name'] ?? 'User',
          taskType: taskType,
          imageUrls: images,
        );
      }).toList();

      setState(() {
        _items = contentItems; // Populate with actual data
        _pendingCount = contentItems.length;
        _isLoading = false;

        if (_items.isNotEmpty) {
          _selectedItem ??= _items.first;
          _selectedImageIndex = 0;
        } else {
          _selectedItem = null;
          _selectedImageIndex = 0;
        }
      });
    } catch (e) {
      print('Error loading pending tasks: $e');
      setState(() {
        _errorMessage = 'Failed to load pending tasks: $e';
        _isLoading = false;
        _pendingCount = 0;
      });
    }
  }

  String _getTaskTitle(String taskType) {
    final titles = {
      'linkedin_post': 'LinkedIn Post',
      'tiktok_video': 'TikTok Video',
      'featured_listing': 'Featured Listing',
      'instagram_story': 'Instagram Story',
      'facebook_boost': 'Facebook Ad',
      'youtube_tour': 'YouTube Tour',
      'email_blast': 'Email Campaign',
      'google_ads': 'Google Ads',
      '1': 'TikTok Listing Walkthrough',
      '2': 'Instagram Market Insight',
      '3': 'YouTube Shorts - Buyer Tip',
      '4': 'AI Calling Campaign',
      '5': 'AI Calling Campaign',
    };
    return titles[taskType] ?? '$taskType Promotion';
  }

  IconData _getTaskIcon(String taskType) {
    if (taskType.contains('video') || taskType.contains('tiktok') || taskType.contains('youtube')) {
      return Icons.play_circle_outline;
    } else if (taskType.contains('image') || taskType.contains('instagram')) {
      return Icons.image_outlined;
    } else if (taskType.contains('email')) {
      return Icons.email_outlined;
    } else if (taskType.contains('linkedin') || taskType.contains('facebook')) {
      return Icons.article_outlined;
    } else {
      return Icons.blur_on_outlined;
    }
  }

  ContentTab _getContentType(String taskType) {
    if (taskType.contains('video') || taskType.contains('tiktok') || taskType.contains('youtube')) {
      return ContentTab.video;
    } else if (taskType.contains('image') || taskType.contains('instagram')) {
      return ContentTab.image;
    } else if (taskType.contains('audio')) {
      return ContentTab.audio;
    } else {
      return ContentTab.writing;
    }
  }

  String _formatTimeAgo(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  Future<void> _approveTask(String taskId) async {
    try {
      final success = await _adminService.approveTask(taskId);
      if (success) {
        _showSuccessSnackBar('Task approved successfully');
        _commentController.clear();
        _loadPendingTasks(); // Refresh the list
      } else {
        _showErrorSnackBar('Failed to approve task');
      }
    } catch (e) {
      _showErrorSnackBar('Error approving task: $e');
    }
  }

  Future<void> _rejectTask(String taskId) async {
    try {
      final comment = _commentController.text.trim();
      final success = await _adminService.rejectTask(
        taskId,
        reason: comment.isEmpty ? null : comment,
      );
      if (success) {
        _showSuccessSnackBar('Task rejected successfully');
        _commentController.clear();
        _loadPendingTasks(); // Refresh the list
      } else {
        _showErrorSnackBar('Failed to reject task');
      }
    } catch (e) {
      _showErrorSnackBar('Error rejecting task: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _realtimeSubscription?.cancel();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildMainContent(),
    );
  }

  // ─── Main Content ─────────────────────────────────────────────────────────
  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top accent line
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, _) => Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.copper.withOpacity(0.7 * _glowAnim.value),
                  AppColors.copperLight.withOpacity(0.9 * _glowAnim.value),
                  AppColors.copper.withOpacity(0.7 * _glowAnim.value),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRow(),
                const SizedBox(height: 16),
                _buildTabBar(),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildContentBody(),
                ),
              ],
            ),
          ),
        ),
        // Bottom accent line
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, _) => Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.copper.withOpacity(0.4 * _glowAnim.value),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Header + Status Row ──────────────────────────────────────────────────
  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Content Approval Queue',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage != null
                  ? 'Unable to load queue'
                  : _pendingCount == 0 && !_isLoading
                      ? 'No pending tasks'
                      : '$_pendingCount item${_pendingCount == 1 ? '' : 's'} awaiting review',
              style: TextStyle(
                color: _errorMessage != null
                    ? AppColors.rejectText
                    : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: _loadPendingTasks,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.copper,
                  ),
                )
              : const Icon(
                  Icons.refresh,
                  color: AppColors.copper,
                  size: 20,
                ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.copper.withOpacity(0.1),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  // ─── Tab Bar ──────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    final tabs = [
      (ContentTab.image, 'Image'),
      (ContentTab.video, 'Video'),
      (ContentTab.audio, 'Audio'),
      (ContentTab.writing, 'Writing'),
    ];

    return Row(
      children: tabs.map((tab) {
        final isActive = _selectedTab == tab.$1;
        return GestureDetector(
          onTap: () => setState(() => _selectedTab = tab.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 2),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
            decoration: BoxDecoration(
              color: isActive ? AppColors.tabActive : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive
                    ? AppColors.copper.withOpacity(0.4)
                    : AppColors.tabBorder.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              tab.$2,
              style: TextStyle(
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Main Two-Panel Layout ────────────────────────────────────────────────
  Widget _buildContentBody() {
    // Filter items based on selected tab
    final filteredItems = _selectedTab == ContentTab.image 
        ? _items.where((item) => item.type == ContentTab.image).toList()
        : _selectedTab == ContentTab.video
            ? _items.where((item) => item.type == ContentTab.video).toList()
            : _selectedTab == ContentTab.audio
                ? _items.where((item) => item.type == ContentTab.audio).toList()
                : _items.where((item) => item.type == ContentTab.writing).toList();

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.copper),
            SizedBox(height: 16),
            Text(
              'Loading pending tasks...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.rejectText,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load tasks',
              style: TextStyle(
                color: AppColors.rejectText,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPendingTasks,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.copper,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    // Ensure selected item is within the filtered list
    final initialSelected = _selectedItem;
    if (initialSelected == null ||
        !filteredItems.any((item) => item.id == initialSelected.id)) {
      _selectedItem = filteredItems.first;
      _selectedImageIndex = 0;
    }

    return Row(
      children: [
        // Left: Approval Feed
        Expanded(
          flex: 3,
          child: _buildApprovalFeed(filteredItems),
        ),
        const SizedBox(width: 24),
        // Right: Preview + Action Panel
        Expanded(
          flex: 4,
          child: _buildPreviewPanel(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.copper.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.copper.withOpacity(0.1),
                      ),
                    ),
                    child: Icon(
                      Icons.inbox_outlined,
                      size: 32,
                      color: AppColors.copper.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Queue is Clear',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All pending tasks for this category have been reviewed.\nAny new requests will appear here in real-time.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Checkbox placeholder
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textMuted, width: 1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          _headerCell('NAME & DETAIL', flex: 5),
          _headerCell('ELAPSED', flex: 3),
          _headerCell('STATUS', flex: 2),
          _headerCell('ACTION CENTER', flex: 4),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTableRow(ContentItem item, int index) {
    final isSelected = _selectedItem?.id == item.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedItem = item;
          _selectedImageIndex = 0;
          _commentController.clear();
        });
      },
      child: _HoverableRow(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? AppColors.copper : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox placeholder
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textMuted, width: 1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              // Thumbnail + Info
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    _buildThumbnail(item),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Time
              Expanded(
                flex: 3,
                child: Text(
                  item.timeAgo,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              // Status badge
              Expanded(
                flex: 2,
                child: _buildStatusBadge(item.status),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(ContentItem item) {
    final primaryUrl = item.primaryImageUrl;

    return Container(
      width: 70,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.copperDim.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.copper.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          children: [
            if (primaryUrl != null)
              Positioned.fill(
                child: Image.network(
                  primaryUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('[AdminApproval] Thumbnail failed: $primaryUrl');
                    return Container(
                      color: AppColors.surfaceDark,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 22,
                          color: AppColors.textMuted.withOpacity(0.8),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      AppColors.copperDim.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    item.previewIcon,
                    size: 22,
                    color: AppColors.copperDim.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Approval Feed (Left Panel) ─────────────────────────────────────────────
  Widget _buildApprovalFeed(List<ContentItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Approval Feed',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.copper.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${items.length}',
                    style: const TextStyle(
                      color: AppColors.copper,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.view_agenda_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          _buildTableHeader(),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => Container(
                height: 1,
                color: AppColors.divider,
              ),
              itemBuilder: (context, index) =>
                  _buildTableRow(items[index], index),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Preview + Action Panel (Right) ────────────────────────────────────────
  Widget _buildPreviewPanel() {
    final item = _selectedItem;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: item == null
          ? const Center(
              child: Text(
                'Select an item from the approval feed to review details.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Preview + Action Panel',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pendingBg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.pendingBorder,
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Pending',
                        style: TextStyle(
                          color: AppColors.pendingText,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.timeAgo,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    children: [
                      // Large visual preview (phone-style)
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMid,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.copperDim.withOpacity(0.4),
                            ),
                          ),
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 9 / 16,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _buildLargePreviewImage(item),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildPreviewThumbnails(item),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Metadata + actions
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Requested by ${item.userName} (${item.userEmail})',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.surfaceDark.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.divider,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Review Notes',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Confirm that this creative matches brand guidelines and includes accurate property details before approving.',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            TextField(
                              controller: _commentController,
                              maxLines: 3,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Add Comment (Optional)',
                                labelStyle: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                                hintText:
                                    'Explain what needs to be changed (shown to user on Request Edit).',
                                hintStyle: TextStyle(
                                  color: AppColors.textMuted.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceDark.withOpacity(0.6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppColors.divider.withOpacity(0.8),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppColors.divider.withOpacity(0.8),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppColors.copper.withOpacity(0.7),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _ActionButton(
                                    icon: Icons.check,
                                    label: 'Approve',
                                    bgColor: AppColors.approveBg,
                                    textColor: AppColors.approveText,
                                    borderColor:
                                        AppColors.approveText.withOpacity(
                                      0.3,
                                    ),
                                    onTap: () => _approveTask(item.id),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ActionButton(
                                    icon: Icons.close,
                                    label: 'Request Edit',
                                    bgColor: AppColors.rejectBg,
                                    textColor: AppColors.rejectText,
                                    borderColor:
                                        AppColors.rejectText.withOpacity(
                                      0.3,
                                    ),
                                    onTap: () => _rejectTask(item.id),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLargePreviewImage(ContentItem item) {
    final images = item.imageUrls;
    if (images.isEmpty) {
      return Container(
        color: AppColors.surfaceDark,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.previewIcon,
                size: 48,
                color: AppColors.copperDim.withOpacity(0.7),
              ),
              const SizedBox(height: 10),
              const Text(
                'No images submitted for this task.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final index = _selectedImageIndex.clamp(0, images.length - 1);
    final url = images[index];

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppColors.surfaceDark,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.copper,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('[AdminApproval] Preview failed: $url');
        return Container(
          color: AppColors.surfaceDark,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 42,
                  color: AppColors.textMuted.withOpacity(0.8),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Failed to load image.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewThumbnails(ContentItem item) {
    final images = item.imageUrls;
    if (images.length <= 1) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final url = images[index];
          final isActive = index == _selectedImageIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedImageIndex = index;
              });
            },
            child: Container(
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isActive
                      ? AppColors.copper
                      : AppColors.copperDim.withOpacity(0.4),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('[AdminApproval] Thumb strip failed: $url');
                    return Container(
                      color: AppColors.surfaceDark,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 18,
                          color: AppColors.textMuted.withOpacity(0.8),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(ContentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.pendingBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.pendingBorder, width: 1),
      ),
      child: const Text(
        'Pending',
        style: TextStyle(
          color: AppColors.pendingText,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

}

// ─── Hoverable Row ─────────────────────────────────────────────────────────────
class _HoverableRow extends StatefulWidget {
  final Widget child;
  const _HoverableRow({required this.child});

  @override
  State<_HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<_HoverableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovered ? AppColors.rowHover : Colors.transparent,
        child: widget.child,
      ),
    );
  }
}

// ─── Action Button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _pressed
                ? widget.bgColor.withOpacity(0.8)
                : _hovered
                ? widget.bgColor.withOpacity(0.9)
                : widget.bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hovered
                  ? widget.textColor.withOpacity(0.5)
                  : widget.borderColor,
              width: 1,
            ),
            boxShadow: _hovered
                ? [
              BoxShadow(
                color: widget.textColor.withOpacity(0.15),
                blurRadius: 8,
              )
            ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 11, color: widget.textColor),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}