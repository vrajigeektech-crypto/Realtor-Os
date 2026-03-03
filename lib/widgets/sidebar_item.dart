import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ─────────────────────────────────────────────────
/// SidebarItem — single nav row in the left sidebar
/// ─────────────────────────────────────────────────
class SidebarItem extends StatefulWidget {
  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.collapsed = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool collapsed;
  final VoidCallback? onTap;

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    final col = widget.collapsed;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: col ? 0 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: active
                ? AppTheme.accent.withOpacity(0.15)
                : _hovered
                    ? Colors.white.withOpacity(0.05)
                    : Colors.transparent,
            border: active
                ? Border.all(color: AppTheme.accent.withOpacity(0.3), width: 1)
                : Border.all(color: Colors.transparent, width: 1),
          ),
          child: Row(
            mainAxisAlignment:
                col ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              // left accent bar
              if (active && !col)
                Container(
                  width: 3,
                  height: 18,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Icon(
                widget.icon,
                size: 18,
                color: active
                    ? AppTheme.accent
                    : _hovered
                        ? AppTheme.textSecondary
                        : AppTheme.textMuted,
              ),
              if (!col) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: active
                          ? AppTheme.textPrimary
                          : _hovered
                              ? AppTheme.textSecondary
                              : AppTheme.textMuted,
                      fontSize: 13.5,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.w400,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
