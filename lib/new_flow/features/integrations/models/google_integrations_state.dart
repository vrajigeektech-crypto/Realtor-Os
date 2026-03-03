import 'google_integration_model.dart';

class GoogleIntegrationsState {
  final bool isLoading;
  final String? error;
  final List<GoogleIntegrationModel> items;
  final Set<String> busyKeys;

  const GoogleIntegrationsState({
    required this.isLoading,
    required this.error,
    required this.items,
    required this.busyKeys,
  });

  const GoogleIntegrationsState.loading()
      : isLoading = true,
        error = null,
        items = const [],
        busyKeys = const {};

  const GoogleIntegrationsState.ready(List<GoogleIntegrationModel> items)
      : isLoading = false,
        error = null,
        items = items,
        busyKeys = const {};

  const GoogleIntegrationsState.error(String message)
      : isLoading = false,
        error = message,
        items = const [],
        busyKeys = const {};

  GoogleIntegrationsState copyWith({
    bool? isLoading,
    String? error,
    List<GoogleIntegrationModel>? items,
    Set<String>? busyKeys,
  }) {
    return GoogleIntegrationsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
      busyKeys: busyKeys ?? this.busyKeys,
    );
  }

  GoogleIntegrationsState setBusy(String integrationKey, bool busy) {
    final next = Set<String>.from(busyKeys);
    if (busy) {
      next.add(integrationKey);
    } else {
      next.remove(integrationKey);
    }
    return copyWith(busyKeys: next);
  }
}
