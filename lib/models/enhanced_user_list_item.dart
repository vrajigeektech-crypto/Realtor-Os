import '../widgets/user_widgets.dart';

/// Enhanced User List Item model for comprehensive user management
/// Maps to enhanced RPC response with all available user data
class EnhancedUserListItem {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? secondaryPhone;
  final String role;
  final String status;
  final String? orgId;
  final String? brokerId;
  final String? teamLeadId;
  final bool onboarded;
  final bool onboardingCompleted;
  final int onboardingStep;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? joinedAt;
  final DateTime? lastLogin;
  final DateTime? lastActivityDate;
  final String? logoUrl;
  final String? headshotUrl;
  final String? writingSample;
  final String? voiceSampleUrl;
  final List<String>? galleryUrls;
  final int galleryCount;
  final String? primaryLogoUrl;
  final String? primaryHeadshotUrl;
  final String? primaryWritingSampleUrl;
  final String? primaryVoiceSampleUrl;
  final double tokensBalance;
  final int xpTotal;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int totalOrders;
  final int approvedQueueCount;
  final bool hasFlags;

  EnhancedUserListItem({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.secondaryPhone,
    required this.role,
    required this.status,
    this.orgId,
    this.brokerId,
    this.teamLeadId,
    required this.onboarded,
    required this.onboardingCompleted,
    required this.onboardingStep,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.joinedAt,
    this.lastLogin,
    this.lastActivityDate,
    this.logoUrl,
    this.headshotUrl,
    this.writingSample,
    this.voiceSampleUrl,
    this.galleryUrls,
    required this.galleryCount,
    this.primaryLogoUrl,
    this.primaryHeadshotUrl,
    this.primaryWritingSampleUrl,
    this.primaryVoiceSampleUrl,
    required this.tokensBalance,
    required this.xpTotal,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalOrders,
    required this.approvedQueueCount,
    required this.hasFlags,
  });

  factory EnhancedUserListItem.fromJson(Map<String, dynamic> json) {
    // Parse date fields
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }

    // Parse gallery URLs array
    List<String>? parseGalleryUrls(dynamic galleryData) {
      if (galleryData == null) return null;
      if (galleryData is List) {
        return galleryData.map((e) => e.toString()).toList();
      }
      return null;
    }

    return EnhancedUserListItem(
      id: json['id'] as String? ?? json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      secondaryPhone: json['secondary_phone'] as String?,
      role: json['role'] as String? ?? 'user',
      status: json['status'] as String? ?? 'active',
      orgId: json['org_id'] as String?,
      brokerId: json['broker_id'] as String?,
      teamLeadId: json['team_lead_id'] as String?,
      onboarded: json['onboarded'] as bool? ?? false,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      onboardingStep: json['onboarding_step'] as int? ?? 0,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),
      joinedAt: parseDate(json['joined_at']),
      lastLogin: parseDate(json['last_login']),
      lastActivityDate: parseDate(json['last_activity_date']),
      logoUrl: json['logo_url'] as String?,
      headshotUrl: json['headshot_url'] as String?,
      writingSample: json['writing_sample'] as String?,
      voiceSampleUrl: json['voice_sample_url'] as String?,
      galleryUrls: parseGalleryUrls(json['gallery_urls']),
      galleryCount: json['gallery_count'] as int? ?? 0,
      primaryLogoUrl: json['primary_logo_url'] as String?,
      primaryHeadshotUrl: json['primary_headshot_url'] as String?,
      primaryWritingSampleUrl: json['primary_writing_sample_url'] as String?,
      primaryVoiceSampleUrl: json['primary_voice_sample_url'] as String?,
      tokensBalance: (json['tokens_balance'] as num?)?.toDouble() ?? 0.0,
      xpTotal: json['xp_total'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      totalOrders: json['total_orders'] as int? ?? 0,
      approvedQueueCount: json['approved_queue_count'] as int? ?? 0,
      hasFlags: json['has_flags'] as bool? ?? false,
    );
  }

  /// Format last login for display
  String get formattedLastLogin {
    if (lastLogin == null) return 'Never';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final loginDate = DateTime(lastLogin!.year, lastLogin!.month, lastLogin!.day);
    
    if (loginDate == today) {
      final hour = lastLogin!.hour;
      final minute = lastLogin!.minute;
      final period = hour >= 12 ? 'pm' : 'am';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return 'Today · $displayHour:${minute.toString().padLeft(2, '0')} $period';
    } else if (loginDate == yesterday) {
      final hour = lastLogin!.hour;
      final minute = lastLogin!.minute;
      final period = hour >= 12 ? 'pm' : 'am';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return 'Yesterday · $displayHour:${minute.toString().padLeft(2, '0')} $period';
    } else {
      return '${lastLogin!.month.toString().padLeft(2, '0')}/${lastLogin!.day.toString().padLeft(2, '0')}/${lastLogin!.year}';
    }
  }

  /// Format last activity for display
  String get formattedLastActivity {
    if (lastActivityDate == null) return 'Never';
    
    final now = DateTime.now();
    final diff = now.difference(lastActivityDate!);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${lastActivityDate!.month}/${lastActivityDate!.day}/${lastActivityDate!.year}';
  }

  /// Format created date for display
  String get formattedCreatedDate {
    return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
  }

  /// Get display status with proper formatting
  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'suspended':
        return 'Suspended';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  /// Get role display with proper formatting
  String get displayRole {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'agent':
        return 'Agent';
      case 'broker':
        return 'Broker';
      case 'user':
        return 'User';
      default:
        return role;
    }
  }

  /// Check if user has completed onboarding
  bool get isFullyOnboarded => onboarded && onboardingCompleted;

  /// Get onboarding progress percentage
  double get onboardingProgress {
    // Assuming 5 steps for onboarding
    return (onboardingStep / 5.0).clamp(0.0, 1.0);
  }

  /// Convert to UserRowData for simple view compatibility
  UserRowData toUserRowData() {
    return UserRowData(
      name: name,
      email: email,
      role: displayRole,
      status: displayStatus,
      lastLogin: formattedLastLogin,
      totalOrders: totalOrders > 0 ? totalOrders.toString() : '--',
      tokenBalance: tokensBalance > 0 ? tokensBalance.toStringAsFixed(2) : '--',
      hasFlags: hasFlags,
    );
  }
}
