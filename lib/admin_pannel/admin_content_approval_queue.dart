import 'dart:async';
import 'package:demo/admin_pannel/shared_admin_navigation.dart';
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
  int _selectedNav = 3; // Content Approval
  ContentTab _selectedTab = ContentTab.image;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;
  
  final AdminApprovalService _adminService = AdminApprovalService();
  List<ContentItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _pendingCount = 0;

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
      
      final contentItems = pendingTasks.map((task) {
        // Map task data to ContentItem
        final taskType = task['task_type'] as String? ?? 'unknown';
        final title = task['user_name'] ?? task['user_email'] ?? 'Anonymous';
        final subtitle = _getTaskTitle(taskType);
        final timeAgo = _formatTimeAgo(task['created_at']);
        final icon = _getTaskIcon(taskType);
        
        return ContentItem(
          id: task['task_id'],
          title: title,
          subtitle: subtitle,
          timeAgo: timeAgo,
          status: ContentStatus.pending,
          type: _getContentType(taskType),
          previewIcon: icon,
          userId: task['user_id'],
          userEmail: task['user_email'] ?? '',
          userName: task['user_name'] ?? 'User',
          taskType: taskType,
        );
      }).toList();

      setState(() {
        _items = contentItems; // Populate with actual data
        _pendingCount = contentItems.length;
        _isLoading = false;
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
      final success = await _adminService.rejectTask(taskId);
      if (success) {
        _showSuccessSnackBar('Task rejected successfully');
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
                // Page title
                const Text(
                  'Content Approval Queue',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_errorMessage != null)
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.rejectText,
                            fontSize: 14,
                          ),
                        ),
                      )
                    else
                      Text(
                        _pendingCount == 0 && !_isLoading 
                            ? 'No pending tasks' 
                            : '$_pendingCount pending task${_pendingCount == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    if (_errorMessage != null)
                      IconButton(
                        onPressed: _loadPendingTasks,
                        icon: const Icon(
                          Icons.refresh,
                          color: AppColors.copper,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.copper.withOpacity(0.1),
                          padding: const EdgeInsets.all(8),
                        ),
                      )
                    else ...[
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
                  ],
                ),
                const SizedBox(height: 24),
                // Tab bar
                _buildTabBar(),
                const SizedBox(height: 20),
                // Table
                Expanded(child: _buildTable()),
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

  // ─── Table ────────────────────────────────────────────────────────────────
  Widget _buildTable() {
    // Filter items based on selected tab
    final filteredItems = _selectedTab == ContentTab.image 
        ? _items.where((item) => item.type == ContentTab.image).toList()
        : _selectedTab == ContentTab.video
            ? _items.where((item) => item.type == ContentTab.video).toList()
            : _selectedTab == ContentTab.audio
                ? _items.where((item) => item.type == ContentTab.audio).toList()
                : _items.where((item) => item.type == ContentTab.writing).toList();

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
            child: _isLoading 
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.copper),
                        SizedBox(height: 16),
                        Text(
                          'Loading pending tasks...',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.rejectText,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load tasks',
                              style: TextStyle(color: AppColors.rejectText, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.copper.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.copper.withOpacity(0.1)),
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
                          )
                        : ListView.separated(
                            itemCount: filteredItems.length,
                            separatorBuilder: (_, __) => Container(
                              height: 1,
                              color: AppColors.divider,
                            ),
                            itemBuilder: (context, index) =>
                                _buildTableRow(filteredItems[index], index),
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
    return _HoverableRow(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox
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
            // Actions
            Expanded(
              flex: 4,
              child: _buildActionButtons(item.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(ContentItem item) {
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
            // Texture overlay
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
            ),
            Center(
              child: Icon(
                item.previewIcon,
                size: 22,
                color: AppColors.copperDim.withOpacity(0.6),
              ),
            ),
          ],
        ),
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

  Widget _buildActionButtons(String itemId) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _ActionButton(
          icon: Icons.check,
          label: 'Approve',
          bgColor: AppColors.approveBg,
          textColor: AppColors.approveText,
          borderColor: AppColors.approveText.withOpacity(0.3),
          onTap: () => _approveTask(itemId),
        ),
        _ActionButton(
          icon: Icons.close,
          label: 'Reject',
          bgColor: AppColors.rejectBg,
          textColor: AppColors.rejectText,
          borderColor: AppColors.rejectText.withOpacity(0.3),
          onTap: () => _rejectTask(itemId),
        ),
        _ActionButton(
          icon: Icons.flag_outlined,
          label: 'Flag',
          bgColor: AppColors.flagBg,
          textColor: AppColors.flagText,
          borderColor: AppColors.flagText.withOpacity(0.3),
          onTap: () {
            // TODO: Implement flag functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Flag functionality coming soon'),
                backgroundColor: AppColors.flagText,
              ),
            );
          },
        ),
      ],
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