import 'package:flutter/material.dart';

enum IntegrationStatus {
  connected,
  configured,
  disconnected,
}

class IntegrationModel {
  final String integrationKey;
  final String displayName;
  final IntegrationStatus status;
  final IconData icon;
  final String? subtitle;
  final DateTime? lastSyncAt;

  const IntegrationModel({
    required this.integrationKey,
    required this.displayName,
    required this.status,
    required this.icon,
    this.subtitle,
    this.lastSyncAt,
  });

  bool get isConnected =>
      status == IntegrationStatus.connected ||
      status == IntegrationStatus.configured;

  factory IntegrationModel.fromJson(Map<String, dynamic> json) {
    return IntegrationModel(
      integrationKey: json['integration_key'] as String,
      displayName: json['display_name'] as String,
      status: _statusFromString(json['status'] as String),
      icon: _iconFromKey(json['integration_key'] as String),
      subtitle: json['meta_note'] as String?,
      lastSyncAt: json['last_sync_at'] == null
          ? null
          : DateTime.parse(json['last_sync_at'] as String),
    );
  }

  static IntegrationStatus _statusFromString(String value) {
    switch (value) {
      case 'connected':
        return IntegrationStatus.connected;
      case 'configured':
        return IntegrationStatus.configured;
      default:
        return IntegrationStatus.disconnected;
    }
  }

  static IconData _iconFromKey(String key) {
    switch (key) {
      case 'stripe':
        return Icons.payments_outlined;
      case 'google':
        return Icons.cloud_outlined;
      case 'facebook':
        return Icons.facebook_outlined;
      case 'hubspot':
        return Icons.hub_outlined;
      default:
        return Icons.extension_outlined;
    }
  }

  IntegrationModel copyWith({
    IntegrationStatus? status,
    String? subtitle,
    DateTime? lastSyncAt,
  }) {
    return IntegrationModel(
      integrationKey: integrationKey,
      displayName: displayName,
      status: status ?? this.status,
      icon: icon,
      subtitle: subtitle ?? this.subtitle,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}
