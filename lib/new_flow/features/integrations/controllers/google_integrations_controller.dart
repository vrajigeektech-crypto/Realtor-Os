import '../models/google_integrations_state.dart';
import '../services/google_integrations_service.dart';

class GoogleIntegrationsController {
  GoogleIntegrationsController({
    GoogleIntegrationsService? service,
  }) : _service = service ?? GoogleIntegrationsService();

  final GoogleIntegrationsService _service;

  GoogleIntegrationsState state = const GoogleIntegrationsState.loading();

  Future<void> load() async {
    state = const GoogleIntegrationsState.loading();

    try {
      final items = await _service.fetchGoogleIntegrations();
      state = GoogleIntegrationsState.ready(items);
    } catch (e) {
      state = GoogleIntegrationsState.error(e.toString());
    }
  }

  Future<void> connect(String integrationKey) async {
    state = state.setBusy(integrationKey, true);

    await _service.startOAuth(integrationKey);

    await load();
  }

  Future<void> disconnect(String integrationKey) async {
    state = state.setBusy(integrationKey, true);

    await _service.disconnectIntegration(integrationKey);

    await load();
  }
}
