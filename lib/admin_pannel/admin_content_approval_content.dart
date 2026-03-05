import 'package:flutter/material.dart';
import '../core/app_colors.dart';

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

  const ContentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.status,
    required this.type,
    required this.previewIcon,
  });
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class AdminContentApprovalContent extends StatefulWidget {
  const AdminContentApprovalContent({super.key});

  @override
  State<AdminContentApprovalContent> createState() => _AdminContentApprovalContentState();
}

class _AdminContentApprovalContentState extends State<AdminContentApprovalContent>
    with SingleTickerProviderStateMixin {
  ContentTab _selectedTab = ContentTab.image;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  final List<ContentItem> _items = [
    ContentItem(
      id: '1',
      title: 'Dark Forest Landscape',
      subtitle: 'photography · 4.2 MB · RAW format',
      timeAgo: '2 minutes ago',
      status: ContentStatus.pending,
      type: ContentTab.image,
      previewIcon: Icons.image_outlined,
    ),
    ContentItem(
      id: '2',
      title: 'Cinematic Title Sequence',
      subtitle: 'mp4 · 1080p · 00:45 duration',
      timeAgo: '2 minutes ago',
      status: ContentStatus.pending,
      type: ContentTab.image,
      previewIcon: Icons.play_circle_outline,
    ),
    ContentItem(
      id: '3',
      title: 'Abstract Motion Study',
      subtitle: 'illustration · vector · layered',
      timeAgo: '2 minutes ago',
      status: ContentStatus.pending,
      type: ContentTab.image,
      previewIcon: Icons.blur_on_outlined,
    ),
    ContentItem(
      id: '4',
      title: 'Editorial Layout Draft',
      subtitle: 'document · 12 pages · InDesign',
      timeAgo: '1 minute ago',
      status: ContentStatus.pending,
      type: ContentTab.image,
      previewIcon: Icons.article_outlined,
    ),
  ];

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
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent line
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.buttonGold.withOpacity(0.7 * _glowAnim.value),
                  AppColors.roseGold.withOpacity(0.9 * _glowAnim.value),
                  AppColors.buttonGold.withOpacity(0.7 * _glowAnim.value),
                  Colors.transparent,
                ],
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
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.buttonGold.withOpacity(0.4 * _glowAnim.value),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
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
              color: isActive ? AppColors.surfaceHigh : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive
                    ? AppColors.buttonGold.withValues(alpha: 0.4)
                    : AppColors.accentBrown.withValues(alpha: 0.5),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentBrown, width: 1),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => Container(
                height: 1,
                color: AppColors.accentBrown,
              ),
              itemBuilder: (context, index) =>
                  _buildTableRow(_items[index], index),
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
        color: AppColors.surfaceHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(
          bottom: BorderSide(color: AppColors.accentBrown, width: 1),
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
          _headerCell('CONTENT FILE', flex: 5),
          _headerCell('FILTERS', flex: 3),
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
                        Container(
                          height: 8,
                          width: 120,
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 6,
                          width: 90,
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(2),
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
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.buttonGold.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonGold.withValues(alpha: 0.08),
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
                    AppColors.buttonGold.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Center(
              child: Icon(
                item.previewIcon,
                size: 22,
                color: AppColors.buttonGold.withValues(alpha: 0.6),
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
        color: Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1),
      ),
      child: const Text(
        'Pending',
        style: TextStyle(
          color: Colors.orange,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButtons(String itemId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.check,
          label: 'Approve',
          bgColor: Colors.green.withValues(alpha: 0.2),
          textColor: Colors.green,
          borderColor: Colors.green.withValues(alpha: 0.3),
          onTap: () {},
        ),
        const SizedBox(width: 6),
        _ActionButton(
          icon: Icons.close,
          label: 'Reject',
          bgColor: Colors.red.withValues(alpha: 0.2),
          textColor: Colors.red,
          borderColor: Colors.red.withValues(alpha: 0.3),
          onTap: () {},
        ),
        const SizedBox(width: 6),
        _ActionButton(
          icon: Icons.flag_outlined,
          label: 'Flag',
          bgColor: AppColors.surfaceHigh,
          textColor: AppColors.roseGold,
          borderColor: AppColors.roseGold.withValues(alpha: 0.3),
          onTap: () {},
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
        color: _hovered ? AppColors.surfaceHigh : Colors.transparent,
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
                ? widget.bgColor.withValues(alpha: 0.8)
                : _hovered
                ? widget.bgColor.withValues(alpha: 1.4)
                : widget.bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hovered
                  ? widget.textColor.withValues(alpha: 0.5)
                  : widget.borderColor,
              width: 1,
            ),
            boxShadow: _hovered
                ? [
              BoxShadow(
                color: widget.textColor.withValues(alpha: 0.15),
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
