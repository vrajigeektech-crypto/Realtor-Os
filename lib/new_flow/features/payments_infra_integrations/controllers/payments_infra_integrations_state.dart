import '../data/models/integration_models.dart';

class PaymentsInfraIntegrationsState {
  final bool isLoading;
  final String? errorMessage;

  final List<IntegrationModel> items;

  /// Keys currently performing connect/disconnect actions.
  final Set<String> busyKeys;

  const PaymentsInfraIntegrationsState({
    required this.isLoading,
    required this.errorMessage,
    required this.items,
    required this.busyKeys,
  });

  const PaymentsInfraIntegrationsState.loading()
      : isLoading = true,
        errorMessage = null,
        items = const [],
        busyKeys = const {};

  const PaymentsInfraIntegrationsState.ready(List<IntegrationModel> items)
      : isLoading = false,
        errorMessage = null,
        items = items,
        busyKeys = const {};

  PaymentsInfraIntegrationsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<IntegrationModel>? items,
    Set<String>? busyKeys,
  }) {
    return PaymentsInfraIntegrationsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      items: items ?? this.items,
      busyKeys: busyKeys ?? this.busyKeys,
    );
  }

  PaymentsInfraIntegrationsState setBusy(String integrationKey, bool busy) {
    final next = Set<String>.from(busyKeys);
    if (busy) {
      next.add(integrationKey);
    } else {
      next.remove(integrationKey);
    }
    return copyWith(busyKeys: next);
  }
}
