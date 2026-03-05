import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SharedAdminNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String? workspaceName;

  const SharedAdminNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.workspaceName = 'Workspace',
  });

  static const List<(IconData, String)> navItems = [
    (Icons.grid_view_rounded, 'Dashboard'),
    (Icons.person_outline_rounded, 'User Management'),
    (Icons.receipt_long_outlined, 'Orders'),
    (Icons.approval_outlined, 'Content Approval'),
    (Icons.task_alt_outlined, 'Tasks'),
    (Icons.block_outlined, 'Activity Log'),
    (Icons.auto_mode_outlined, 'Automation'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 218,
      color: AppColors.surfaceHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workspace chip
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.accentBrown),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.home_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(workspaceName!,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Nav items
          ...navItems.asMap().entries.map((e) => _NavTile(
            icon: e.value.$1,
            label: e.value.$2,
            selected: e.key == selectedIndex,
            onTap: () => onSelect(e.key),
          )),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: sel
                ? AppColors.buttonGold.withValues(alpha: 0.2)
                : _hovered
                ? AppColors.cardBackground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: sel
                ? const Border(left: BorderSide(color: AppColors.buttonGold, width: 2))
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.icon,
                  size: 15,
                  color: sel
                      ? AppColors.buttonGold
                      : _hovered
                      ? AppColors.textPrimary
                      : AppColors.textSecondary),
              const SizedBox(width: 10),
              Text(widget.label,
                  style: TextStyle(
                    color: sel
                        ? AppColors.textPrimary
                        : _hovered
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: sel ? FontWeight.w500 : FontWeight.w400,
                    letterSpacing: 0.2,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
