import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class EnhancedUserRowData {
  const EnhancedUserRowData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.lastLogin,
    required this.lastActivity,
    required this.createdDate,
    required this.totalOrders,
    required this.tokenBalance,
    required this.xpTotal,
    required this.level,
    required this.currentStreak,
    required this.onboardingStatus,
    required this.hasFlags,
    required this.galleryCount,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String status;
  final String lastLogin;
  final String lastActivity;
  final String createdDate;
  final String totalOrders;
  final String tokenBalance;
  final String xpTotal;
  final String level;
  final String currentStreak;
  final String onboardingStatus;
  final bool hasFlags;
  final String galleryCount;

  static int flexForIndex(int i) {
    switch (i) {
      case 0: return 3;  // name
      case 1: return 4;  // email
      case 2: return 2;  // phone
      case 3: return 2;  // role
      case 4: return 2;  // status
      case 5: return 3;  // last login
      case 6: return 3;  // last activity
      case 7: return 2;  // created
      case 8: return 2;  // orders
      case 9: return 2;  // tokens
      case 10: return 1; // xp
      case 11: return 1; // level
      case 12: return 1; // streak
      case 13: return 2; // onboarding
      case 14: return 1; // gallery
      case 15: return 1; // flags
      case 16: return 1; // actions
      default: return 2;
    }
  }
}

class EnhancedUserTableRow extends StatelessWidget {
  const EnhancedUserTableRow({super.key, required this.row, this.selected = false});

  final EnhancedUserRowData row;
  final bool selected;

  Color get statusColor {
    switch (row.status) {
      case 'Active': return AppStyles.statusGreen;
      case 'Inactive': return AppStyles.statusGray;
      case 'Suspended': return AppStyles.statusRed;
      case 'Pending': return Colors.orange;
      default: return AppStyles.statusYellow;
    }
  }

  Color get onboardingColor {
    switch (row.onboardingStatus) {
      case 'Complete': return AppStyles.statusGreen;
      case 'In Progress': return Colors.orange;
      case 'Not Started': return AppStyles.statusGray;
      default: return AppStyles.statusGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected ? AppStyles.selectedColor : Colors.transparent,
      child: Column(
        children: [
          SizedBox(
            height: 56, // Increased height for more data
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  // Name
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(0),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: selected ? AppStyles.accentColor : AppStyles.mutedText,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            row.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Email
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(1),
                    child: Text(
                      row.email,
                      style: const TextStyle(
                        color: AppStyles.mutedText,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Phone
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(2),
                    child: Text(
                      row.phone ?? '--',
                      style: const TextStyle(
                        color: AppStyles.mutedText,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Role
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(3),
                    child: _RoleBadge(role: row.role),
                  ),
                  // Status
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(4),
                    child: _StatusCell(status: row.status, color: statusColor),
                  ),
                  // Last Login
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(5),
                    child: Text(
                      row.lastLogin,
                      style: const TextStyle(
                        color: AppStyles.mutedText,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Last Activity
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(6),
                    child: Text(
                      row.lastActivity,
                      style: const TextStyle(
                        color: AppStyles.mutedText,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Created Date
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(7),
                    child: Text(
                      row.createdDate,
                      style: const TextStyle(
                        color: AppStyles.mutedText,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Total Orders
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(8),
                    child: Text(
                      row.totalOrders,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Token Balance
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(9),
                    child: Text(
                      row.tokenBalance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // XP Total
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(10),
                    child: Text(
                      row.xpTotal,
                      style: const TextStyle(
                        color: AppStyles.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Level
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(11),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppStyles.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppStyles.accentColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'Lvl ${row.level}',
                        style: const TextStyle(
                          color: AppStyles.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Current Streak
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(12),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          row.currentStreak,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Onboarding Status
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(13),
                    child: _OnboardingCell(status: row.onboardingStatus, color: onboardingColor),
                  ),
                  // Gallery Count
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(14),
                    child: Row(
                      children: [
                        const Icon(Icons.photo_library, color: AppStyles.mutedText, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          row.galleryCount,
                          style: const TextStyle(
                            color: AppStyles.mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Flags
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(15),
                    child: row.hasFlags
                        ? const Icon(Icons.flag, color: Colors.red, size: 14)
                        : const Icon(Icons.flag_outlined, color: AppStyles.mutedText, size: 14),
                  ),
                  // Actions
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(16),
                    child: const _RowActions(),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppStyles.borderSoft),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  
  const _RoleBadge({required this.role});

  Color get badgeColor {
    switch (role) {
      case 'Admin': return Colors.red;
      case 'Broker': return Colors.blue;
      case 'Agent': return Colors.green;
      default: return AppStyles.mutedText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  final String status;
  final Color color;
  
  const _StatusCell({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 3, spreadRadius: 1)],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _OnboardingCell extends StatelessWidget {
  final String status;
  final Color color;
  
  const _OnboardingCell({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconBtn(icon: Icons.visibility_outlined),
        const SizedBox(width: 4),
        _IconBtn(icon: Icons.edit_outlined),
        const SizedBox(width: 4),
        _IconBtn(icon: Icons.message_outlined),
      ],
    );
  }
}

class _IconBtn extends StatefulWidget {
  final IconData icon;
  
  const _IconBtn({required this.icon});

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _hovered = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Icon(
        widget.icon,
        size: 14,
        color: _hovered ? AppStyles.accentColor : AppStyles.mutedText,
      ),
    );
  }
}
