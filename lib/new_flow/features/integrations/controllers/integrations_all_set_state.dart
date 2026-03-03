import '../models/integration_group_model.dart';

class IntegrationsAllSetState {
  final bool loadingHeader;
  final bool loadingGrid;
  final String? error;

  final String? headerTitle;
  final String? headerSubtitle;
  final int? connectedCount;
  final int? totalCount;
  final int? completionPercent;

  final List<IntegrationGroupModel> groups;
  final Set<String> busyKeys;

  const IntegrationsAllSetState({
    required this.loadingHeader,
    required this.loadingGrid,
    required this.error,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.connectedCount,
    required this.totalCount,
    required this.completionPercent,
    required this.groups,
    required this.busyKeys,
  });

  const IntegrationsAllSetState.loading()
      : loadingHeader = true,
        loadingGrid = true,
        error = null,
        headerTitle = null,
        headerSubtitle = null,
        connectedCount = null,
        totalCount = null,
        completionPercent = null,
        groups = const [],
        busyKeys = const {};

  const IntegrationsAllSetState.ready({
    required String headerTitle,
    required String headerSubtitle,
    required int connectedCount,
    required int totalCount,
    required int completionPercent,
    required List<IntegrationGroupModel> groups,
  })  : loadingHeader = false,
        loadingGrid = false,
        error = null,
        headerTitle = headerTitle,
        headerSubtitle = headerSubtitle,
        connectedCount = connectedCount,
        totalCount = totalCount,
        completionPercent = completionPercent,
        groups = groups,
        busyKeys = const {};

  const IntegrationsAllSetState.error(String message)
      : loadingHeader = false,
        loadingGrid = false,
        error = message,
        headerTitle = null,
        headerSubtitle = null,
        connectedCount = null,
        totalCount = null,
        completionPercent = null,
        groups = const [],
        busyKeys = const {};

  IntegrationsAllSetState copyWith({
    bool? loadingHeader,
    bool? loadingGrid,
    String? error,
    String? headerTitle,
    String? headerSubtitle,
    int? connectedCount,
    int? totalCount,
    int? completionPercent,
    List<IntegrationGroupModel>? groups,
    Set<String>? busyKeys,
  }) {
    return IntegrationsAllSetState(
      loadingHeader: loadingHeader ?? this.loadingHeader,
      loadingGrid: loadingGrid ?? this.loadingGrid,
      error: error,
      headerTitle: headerTitle ?? this.headerTitle,
      headerSubtitle: headerSubtitle ?? this.headerSubtitle,
      connectedCount: connectedCount ?? this.connectedCount,
      totalCount: totalCount ?? this.totalCount,
      completionPercent: completionPercent ?? this.completionPercent,
      groups: groups ?? this.groups,
      busyKeys: busyKeys ?? this.busyKeys,
    );
  }

  IntegrationsAllSetState setBusy(String integrationKey, bool busy) {
    final next = Set<String>.from(busyKeys);
    if (busy) {
      next.add(integrationKey);
    } else {
      next.remove(integrationKey);
    }
    return copyWith(busyKeys: next);
  }
}
