import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/sidebar_item.dart';

/// ─────────────────────────────────────────────────
/// ResponsiveShell
/// ─────────────────────────────────────────────────
/// Wraps any screen with:
///  • Desktop  → fixed collapsible left sidebar + body
///  • Tablet   → icon-only collapsed sidebar + body
///  • Mobile   → Drawer (hamburger) + body
///
/// Usage:
///   ResponsiveShell(
///     activeIndex: 2,   // Wallet
///     child: WalletContent(),
///   )
/// ─────────────────────────────────────────────────

class _NavEntry {
  const _NavEntry({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

const _navItems = [
  _NavEntry(icon: Icons.grid_view_rounded,      label: 'Dashboard'),
  _NavEntry(icon: Icons.home_work_rounded,       label: 'Properties'),
  _NavEntry(icon: Icons.account_balance_wallet,  label: 'Wallet'),
  _NavEntry(icon: Icons.handshake_rounded,       label: 'Agreements'),
  _NavEntry(icon: Icons.folder_rounded,          label: 'Files'),
  _NavEntry(icon: Icons.auto_mode_rounded,       label: 'Automation'),
  _NavEntry(icon: Icons.settings_rounded,        label: 'Settings'),
  _NavEntry(icon: Icons.admin_panel_settings,    label: 'Admin'),
  _NavEntry(icon: Icons.task_alt_rounded,        label: 'Task'),
  _NavEntry(icon: Icons.call_rounded,            label: 'Call'),
];

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({
    super.key,
    required this.child,
    this.activeIndex = 2,
    this.onNavTap,
  });

  final Widget child;
  final int activeIndex;
  final void Function(int index)? onNavTap;

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell>
    with SingleTickerProviderStateMixin {
  // Desktop sidebar can be expanded (200 px) or collapsed (64 px)
  bool _sidebarExpanded = true;

  // Sidebar panel animation
  late AnimationController _animCtrl;
  late Animation<double> _widthAnim;

  static const double _expandedW  = 208;
  static const double _collapsedW =  64;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1.0,
    );
    _widthAnim = Tween<double>(begin: _collapsedW, end: _expandedW).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() => _sidebarExpanded = !_sidebarExpanded);
    _sidebarExpanded ? _animCtrl.forward() : _animCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (ctx, size) {
        switch (size) {
          case ScreenSize.desktop:
            return _DesktopLayout(
              animCtrl: _animCtrl,
              widthAnim: _widthAnim,
              expanded: _sidebarExpanded,
              onToggle: _toggleSidebar,
              activeIndex: widget.activeIndex,
              onNavTap: widget.onNavTap,
              child: widget.child,
            );
          case ScreenSize.tablet:
            return _TabletLayout(
              activeIndex: widget.activeIndex,
              onNavTap: widget.onNavTap,
              child: widget.child,
            );
          case ScreenSize.mobile:
            return _MobileLayout(
              activeIndex: widget.activeIndex,
              onNavTap: widget.onNavTap,
              child: widget.child,
            );
        }
      },
    );
  }
}

// ══════════════════════════════════════════════════
// DESKTOP LAYOUT — animated collapsible sidebar
// ══════════════════════════════════════════════════
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.animCtrl,
    required this.widthAnim,
    required this.expanded,
    required this.onToggle,
    required this.activeIndex,
    required this.onNavTap,
    required this.child,
  });

  final AnimationController animCtrl;
  final Animation<double> widthAnim;
  final bool expanded;
  final VoidCallback onToggle;
  final int activeIndex;
  final void Function(int)? onNavTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Row(
        children: [
          // ── Animated Sidebar ──────────────────────
          AnimatedBuilder(
            animation: widthAnim,
            builder: (ctx, _) {
              final w = widthAnim.value;
              final collapsed = w < 100;
              return _SidebarPanel(
                width: w,
                collapsed: collapsed,
                expanded: expanded,
                onToggle: onToggle,
                activeIndex: activeIndex,
                onNavTap: onNavTap,
              );
            },
          ),
          // ── Main Area ─────────────────────────────
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// TABLET LAYOUT — icon-only fixed sidebar
// ══════════════════════════════════════════════════
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.activeIndex,
    required this.onNavTap,
    required this.child,
  });
  final int activeIndex;
  final void Function(int)? onNavTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Row(
        children: [
          _SidebarPanel(
            width: 64,
            collapsed: true,
            expanded: false,
            onToggle: () {},
            activeIndex: activeIndex,
            onNavTap: onNavTap,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// MOBILE LAYOUT — Drawer
// ══════════════════════════════════════════════════
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.activeIndex,
    required this.onNavTap,
    required this.child,
  });
  final int activeIndex;
  final void Function(int)? onNavTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSidebar,
        elevation: 0,
        toolbarHeight: 52,
        titleSpacing: 4,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded,
                color: AppTheme.textSecondary, size: 22),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            _OstLogo(size: 28),
            const SizedBox(width: 8),
            const Text(
              'Realtor OS',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppTheme.bgSidebar,
        width: 220,
        child: SafeArea(
          child: _SidebarContent(
            collapsed: false,
            activeIndex: activeIndex,
            onNavTap: (idx) {
              Navigator.of(context).pop();
              onNavTap?.call(idx);
            },
          ),
        ),
      ),
      body: child,
    );
  }
}

// ══════════════════════════════════════════════════
// SIDEBAR PANEL — shared between desktop & tablet
// ══════════════════════════════════════════════════
class _SidebarPanel extends StatelessWidget {
  const _SidebarPanel({
    required this.width,
    required this.collapsed,
    required this.expanded,
    required this.onToggle,
    required this.activeIndex,
    required this.onNavTap,
  });

  final double width;
  final bool collapsed;
  final bool expanded;
  final VoidCallback onToggle;
  final int activeIndex;
  final void Function(int)? onNavTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.bgSidebar,
        border: const Border(
          right: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // ── Logo row ────────────────────────────
          _LogoRow(collapsed: collapsed, onToggle: onToggle),
          const Divider(color: AppTheme.borderColor, height: 1),
          const SizedBox(height: 8),
          // ── Nav items ───────────────────────────
          Expanded(
            child: _SidebarContent(
              collapsed: collapsed,
              activeIndex: activeIndex,
              onNavTap: onNavTap,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo / branding row ───────────────────────────
class _LogoRow extends StatelessWidget {
  const _LogoRow({required this.collapsed, required this.onToggle});
  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const SizedBox(width: 12),
          _OstLogo(size: 32),
          if (!collapsed) ...[
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Realtor OS',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          IconButton(
            icon: Icon(
              collapsed
                  ? Icons.chevron_right_rounded
                  : Icons.chevron_left_rounded,
              color: AppTheme.textMuted,
              size: 20,
            ),
            onPressed: onToggle,
            tooltip: collapsed ? 'Expand' : 'Collapse',
          ),
        ],
      ),
    );
  }
}

// ── Nav list content ──────────────────────────────
class _SidebarContent extends StatelessWidget {
  const _SidebarContent({
    required this.collapsed,
    required this.activeIndex,
    required this.onNavTap,
  });
  final bool collapsed;
  final int activeIndex;
  final void Function(int)? onNavTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < _navItems.length; i++)
            SidebarItem(
              icon: _navItems[i].icon,
              label: _navItems[i].label,
              isActive: i == activeIndex,
              collapsed: collapsed,
              onTap: () => onNavTap?.call(i),
            ),
        ],
      ),
    );
  }
}

// ── OST Logo avatar ──────────────────────────────
class _OstLogo extends StatelessWidget {
  const _OstLogo({this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.accentGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'OST',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.28,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
