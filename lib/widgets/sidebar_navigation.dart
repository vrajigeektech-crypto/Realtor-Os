import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';

class SidebarNavigation extends StatefulWidget {
  const SidebarNavigation({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
    this.isCollapsed = false,
  });

  final String selectedItem;
  final Function(String) onItemSelected;
  final bool isCollapsed;

  @override
  State<SidebarNavigation> createState() => _SidebarNavigationState();
}

class _SidebarNavigationState extends State<SidebarNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _collapseController;
  late Animation<double> _collapseAnimation;

  @override
  void initState() {
    super.initState();
    _collapseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _collapseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _collapseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _collapseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SidebarNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _collapseController.forward();
      } else {
        _collapseController.reverse();
      }
    }
  }

  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
    {'icon': Icons.apartment_outlined, 'label': 'Properties'},
    {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet'},
    {'icon': Icons.description_outlined, 'label': 'Agreements'},
    {'icon': Icons.folder_outlined, 'label': 'Files'},
    {'icon': Icons.auto_awesome_outlined, 'label': 'Automation'},
    {'icon': Icons.settings_outlined, 'label': 'Settings'},
    {'icon': Icons.admin_panel_settings_outlined, 'label': 'Admin'},
    {'icon': Icons.task_outlined, 'label': 'Task'},
    {'icon': Icons.phone_outlined, 'label': 'Call'},
  ];

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _collapseAnimation,
      builder: (context, child) {
        final width = widget.isCollapsed ? 80.0 : 280.0;
        
        return Container(
          width: width,
          decoration: BoxDecoration(
            color: AppTheme.bgSidebar,
            border: Border(
              right: BorderSide(color: AppTheme.borderColor, width: 1),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                height: 80,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isCollapsed ? 16 : 24,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'OST',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    if (!widget.isCollapsed) ...[
                      const SizedBox(width: 12),
                      const Text(
                        'Realtor OS',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Menu Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    final isSelected = item['label'] == widget.selectedItem;
                    
                    return SidebarItem(
                      icon: item['icon'],
                      label: item['label'],
                      isSelected: isSelected,
                      isCollapsed: widget.isCollapsed,
                      onTap: () => widget.onItemSelected(item['label']),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SidebarItem extends StatefulWidget {
  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 8 : 16,
            vertical: 2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 16 : 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.accent.withOpacity(0.15)
                : _hoverAnimation.value > 0
                    ? AppTheme.bgCardHover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: widget.isSelected
                ? Border.all(color: AppTheme.accent.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected ? AppTheme.accent : AppTheme.textSecondary,
                size: 22,
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isSelected ? AppTheme.accent : AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
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
