class GoogleIntegrationModel {
  final String integrationKey; // calendar | my_business | contacts | drive
  final String displayName;
  final String description;
  final bool connected;
  final DateTime? lastSyncedAt;

  const GoogleIntegrationModel({
    required this.integrationKey,
    required this.displayName,
    required this.description,
    required this.connected,
    this.lastSyncedAt,
  });

  factory GoogleIntegrationModel.fromJson(Map<String, dynamic> json) {
    return GoogleIntegrationModel(
      integrationKey: json['integration_key'] as String,
      displayName: json['display_name'] as String,
      description: json['description'] as String,
      connected: json['connected'] as bool,
      lastSyncedAt: json['last_synced_at'] == null
          ? null
          : DateTime.parse(json['last_synced_at'] as String),
    );
  }

  GoogleIntegrationModel copyWith({
    bool? connected,
    DateTime? lastSyncedAt,
  }) {
    return GoogleIntegrationModel(
      integrationKey: integrationKey,
      displayName: displayName,
      description: description,
      connected: connected ?? this.connected,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
