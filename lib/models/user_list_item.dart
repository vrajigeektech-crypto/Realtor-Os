import '../widgets/user_widgets.dart';

/// User List Item model for user management table
/// Maps to RPC response for user list
class UserListItem {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime? lastLogin;
  final int totalOrders;
  final int tokenBalance;
  final int approvedQueueCount;
  final bool hasFlags;

  UserListItem({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.lastLogin,
    required this.totalOrders,
    required this.tokenBalance,
    required this.approvedQueueCount,
    required this.hasFlags,
  });

  factory UserListItem.fromJson(Map<String, dynamic> json) {
    // Parse last_login
    DateTime? lastLogin;
    final lastLoginStr = json['last_login'] as String? ?? json['lastLogin'] as String?;
    if (lastLoginStr != null && lastLoginStr.isNotEmpty) {
      try {
        lastLogin = DateTime.parse(lastLoginStr);
      } catch (e) {
        lastLogin = null;
      }
    }

    return UserListItem(
      id: json['id'] as String? ?? json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'Agent',
      status: json['status'] as String? ?? 'active',
      lastLogin: lastLogin,
      totalOrders: json['total_orders'] as int? ?? json['totalOrders'] as int? ?? 0,
      tokenBalance: (json['token_balance'] is num 
                  ? json['token_balance'].toInt() 
                  : (json['token_balance'] as String? ?? '').isNotEmpty 
                    ? int.tryParse(json['token_balance'] as String) ?? 0
                    : (json['token_balance'] as int? ?? 0)),
      approvedQueueCount: json['approved_queue_count'] as int? ?? 0,
      hasFlags: json['has_flags'] as bool? ?? json['hasFlags'] as bool? ?? false,
    );
  }

  /// Format last login for display
  String get formattedLastLogin {
    if (lastLogin == null) return 'Never';
    
    // Always show date format: MM/DD/YYYY
    return '${lastLogin!.month.toString().padLeft(2, '0')}/${lastLogin!.day.toString().padLeft(2, '0')}/${lastLogin!.year}';
  }

  /// Convert to UserRowData for display
  UserRowData toUserRowData() {
    return UserRowData(
      name: name,
      email: email,
      role: role,
      status: status == 'active' ? 'Active' : (status == 'inactive' ? 'Inactive' : 'Suspended'),
      lastLogin: formattedLastLogin,
      totalOrders: totalOrders > 0 ? totalOrders.toString() : '--',
      tokenBalance: tokenBalance > 0 ? tokenBalance.toString() : '--',
      hasFlags: hasFlags,
    );
  }
}
