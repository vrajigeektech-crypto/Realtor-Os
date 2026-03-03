class SocialIntegrationModel {
  final String integrationKey;
  final String displayName;
  final String group; // social | ads | crm
  final bool connected;
  final DateTime? lastSyncedAt;

  const SocialIntegrationModel({
    required this.integrationKey,
    required this.displayName,
    required this.group,
    required this.connected,
    required this.lastSyncedAt,
  });

  factory SocialIntegrationModel.fromJson(Map<String, dynamic> json) {
    return SocialIntegrationModel(
      integrationKey: json['integration_key'] as String,
      displayName: json['display_name'] as String,
      group: json['group'] as String,
      connected: json['connected'] as bool,
      lastSyncedAt: json['last_synced_at'] == null
          ? null
          : DateTime.parse(json['last_synced_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'integration_key': integrationKey,
      'display_name': displayName,
      'group': group,
      'connected': connected,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  SocialIntegrationModel copyWith({
    bool? connected,
    DateTime? lastSyncedAt,
  }) {
    return SocialIntegrationModel(
      integrationKey: integrationKey,
      displayName: displayName,
      group: group,
      connected: connected ?? this.connected,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
