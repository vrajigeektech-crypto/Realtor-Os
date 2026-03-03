import 'package:flutter/foundation.dart';

@immutable
class SocialMediaIntegrationsState {
  final String? userId;

  final bool isLoading;
  final bool isMutating;

  final String? headerTitle;
  final String? headerSubtitle;

  final List<SocialIntegrationItem> items;

  final String searchQuery;
  final String platformGroup;

  final String? selectedIntegrationKey;

  final String? error;
  final DateTime? lastRefreshedAt;

  const SocialMediaIntegrationsState({
    required this.userId,
    required this.isLoading,
    required this.isMutating,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.items,
    required this.searchQuery,
    required this.platformGroup,
    required this.selectedIntegrationKey,
    required this.error,
    required this.lastRefreshedAt,
  });

  const SocialMediaIntegrationsState.initial()
      : userId = null,
        isLoading = false,
        isMutating = false,
        headerTitle = null,
        headerSubtitle = null,
        items = const [],
        searchQuery = '',
        platformGroup = 'all',
        selectedIntegrationKey = null,
        error = null,
        lastRefreshedAt = null;

  SocialMediaIntegrationsState copyWith({
    String? userId,
    bool? isLoading,
    bool? isMutating,
    String? headerTitle,
    String? headerSubtitle,
    List<SocialIntegrationItem>? items,
    String? searchQuery,
    String? platformGroup,
    String? selectedIntegrationKey,
    String? error,
    DateTime? lastRefreshedAt,
  }) {
    return SocialMediaIntegrationsState(
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      headerTitle: headerTitle ?? this.headerTitle,
      headerSubtitle: headerSubtitle ?? this.headerSubtitle,
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      platformGroup: platformGroup ?? this.platformGroup,
      selectedIntegrationKey:
          selectedIntegrationKey ?? this.selectedIntegrationKey,
      error: error,
      lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
    );
  }

  List<SocialIntegrationItem> get filteredItems {
    return items.where((item) {
      final matchesSearch = searchQuery.isEmpty ||
          item.displayName
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      final matchesGroup =
          platformGroup == 'all' || item.group == platformGroup;

      return matchesSearch && matchesGroup;
    }).toList();
  }

  String? get errorMessage => error;
  Set<String> get busyKeys => const {};
}

@immutable
class SocialIntegrationItem {
  final String integrationKey;
  final String displayName;
  final String group;
  final bool connected;
  final DateTime? lastSyncedAt;

  const SocialIntegrationItem({
    required this.integrationKey,
    required this.displayName,
    required this.group,
    required this.connected,
    required this.lastSyncedAt,
  });

  SocialIntegrationItem copyWith({
    bool? connected,
    DateTime? lastSyncedAt,
  }) {
    return SocialIntegrationItem(
      integrationKey: integrationKey,
      displayName: displayName,
      group: group,
      connected: connected ?? this.connected,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
