import 'package:flutter/foundation.dart';

import '../data/models/integration_models.dart';
import '../data/repositories/payments_infra_integrations_repository.dart';
import 'payments_infra_integrations_state.dart';

class PaymentsInfraIntegrationsController {
  PaymentsInfraIntegrationsController({
    PaymentsInfraIntegrationsRepository? repository,
  }) : _repository = repository ?? PaymentsInfraIntegrationsRepository();

  final PaymentsInfraIntegrationsRepository _repository;

  final ValueNotifier<PaymentsInfraIntegrationsState> _state =
      ValueNotifier(const PaymentsInfraIntegrationsState.loading());

  ValueListenable<PaymentsInfraIntegrationsState> get state => _state;

  Future<void> loadIntegrations(String userId) async {
    _state.value = const PaymentsInfraIntegrationsState.loading();

    final items = await _repository.fetchIntegrations(userId: userId);

    _state.value = PaymentsInfraIntegrationsState.ready(items);
  }

  Future<void> connect(String userId, String integrationKey) async {
    _state.value = _state.value.setBusy(integrationKey, true);

    await _repository.connectIntegration(
      userId: userId,
      integrationKey: integrationKey,
    );

    await loadIntegrations(userId);
  }

  Future<void> disconnect(String userId, String integrationKey) async {
    _state.value = _state.value.setBusy(integrationKey, true);

    await _repository.disconnectIntegration(
      userId: userId,
      integrationKey: integrationKey,
    );

    await loadIntegrations(userId);
  }

  void dispose() {
    _state.dispose();
  }
}
