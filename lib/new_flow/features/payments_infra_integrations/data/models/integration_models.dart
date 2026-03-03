import 'package:flutter/material.dart';

class IntegrationModel {
  final String integrationKey;
  final String displayName;
  final String providerGroup; // payments_infra | social | ads | crm
  final bool connected;
  final DateTime? lastSyncedAt;
  final String? subtitle;
  final String? imagePath;

  const IntegrationModel({
    required this.integrationKey,
    required this.displayName,
    required this.providerGroup,
    required this.connected,
    this.lastSyncedAt,
    this.subtitle,
    this.imagePath,
  });

  factory IntegrationModel.fromJson(Map<String, dynamic> json) {
    return IntegrationModel(
      integrationKey: json['integration_key'] as String,
      displayName: json['display_name'] as String,
      providerGroup: json['provider_group'] as String,
      connected: json['connected'] as bool,
      lastSyncedAt: json['last_synced_at'] == null
          ? null
          : DateTime.parse(json['last_synced_at'] as String),
      subtitle: json['subtitle'] as String?,
      imagePath: _imagePathFromKey(json['integration_key'] as String),
    );
  }

  static String? _imagePathFromKey(String key) {
    switch (key) {
      case 'stripe':
        return 'assets/stripe_logo.png';
      case 'plaid':
        return 'assets/plaid_logo.png';
      case 'zapier':
        return 'assets/zapier_logo.png';
      default:
        return null;
    }
  }

  IconData get icon {
    switch (integrationKey) {
      case 'stripe':
        return Icons.payments;
      case 'plaid':
        return Icons.account_balance;
      case 'zapier':
        return Icons.sync_alt;
      case 'webhooks':
        return Icons.api;
      default:
        return Icons.extension;
    }
  }

  IntegrationModel copyWith({
    bool? connected,
    DateTime? lastSyncedAt,
    String? subtitle,
  }) {
    return IntegrationModel(
      integrationKey: integrationKey,
      displayName: displayName,
      providerGroup: providerGroup,
      connected: connected ?? this.connected,
      imagePath: imagePath,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}
