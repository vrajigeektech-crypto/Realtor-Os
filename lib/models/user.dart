class User {
  final String id;
  final String name;
  final String title;
  final String company;
  final bool isActive;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.isActive,
    this.profileImageUrl,
  });

  // Factory constructor from RPC: get_agent_profile_header
  // RPC Output: { id, full_name, first_name, last_name, role, status, avatar_url, brokerage_id, brokerage_name }
  factory User.fromRpcJson(Map<String, dynamic> json) {
    final fullName = json['full_name'] as String? ?? '';
    final role = json['role'] as String? ?? '';
    final status = json['status'] as String? ?? '';
    final brokerageName = json['brokerage_name'] as String? ?? '';
    final avatarUrl = json['avatar_url'] as String?;

    return User(
      id: json['id'] as String,
      name: fullName,
      title: role,
      company: brokerageName,
      isActive: status.toLowerCase() == 'active',
      profileImageUrl: avatarUrl,
    );
  }

  // Legacy fromJson for backward compatibility
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      isActive: json['isActive'] as bool,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'company': company,
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
    };
  }
}
