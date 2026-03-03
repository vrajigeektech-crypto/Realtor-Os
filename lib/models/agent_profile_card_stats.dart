/// Agent Profile Card Stats model from RPC: get_agent_profile_card_stats
/// RPC Output: { full_name, email, role, status, total_orders, tokens, last_login }
class AgentProfileCardStats {
  final String fullName;
  final String email;
  final String role;
  final String status;
  final int totalOrders;
  final int tokens;
  final DateTime? lastLogin;

  AgentProfileCardStats({
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    required this.totalOrders,
    required this.tokens,
    this.lastLogin,
  });

  factory AgentProfileCardStats.fromJson(Map<String, dynamic> json) {
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

    return AgentProfileCardStats(
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'Agent',
      status: json['status'] as String? ?? 'active',
      totalOrders: json['total_orders'] as int? ?? json['totalOrders'] as int? ?? 0,
      tokens: json['tokens'] as int? ?? 0,
      lastLogin: lastLogin,
    );
  }

  /// Get initials from full name (first letter)
  String get initials {
    if (fullName.isEmpty) return '?';
    return fullName[0].toUpperCase();
  }

  /// Format last login date as MM/DD/YYYY
  String get formattedLastLogin {
    if (lastLogin == null) return 'Never';
    return '${lastLogin!.month.toString().padLeft(2, '0')}/${lastLogin!.day.toString().padLeft(2, '0')}/${lastLogin!.year}';
  }

  /// Check if status is active
  bool get isActive => status.toLowerCase() == 'active';
}
