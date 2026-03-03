import 'package:flutter/material.dart';
import '../controllers/integrations_all_set_state.dart';
import '../services/integrations_service.dart';

class IntegrationsAllSetController {
  IntegrationsAllSetController({required this.userId});

  final String userId;
  final IntegrationsService _service = IntegrationsService();

  final ValueNotifier<IntegrationsAllSetState> state =
      ValueNotifier(const IntegrationsAllSetState.loading());

  Future<void> load() async {
    state.value = const IntegrationsAllSetState.loading();

    try {
      final header = await _service.fetchAllSetHeader(userId);
      final groups = await _service.fetchAllSetGrid(userId);

      state.value = IntegrationsAllSetState.ready(
        headerTitle: header.title,
        headerSubtitle: header.subtitle,
        connectedCount: header.connectedCount,
        totalCount: header.totalCount,
        completionPercent: header.completionPercent,
        groups: groups,
      );
    } catch (e) {
      state.value = IntegrationsAllSetState.error(e.toString());
    }
  }

  Future<void> onPrimaryAction(
    BuildContext context,
    String integrationKey,
  ) async {
    state.value = state.value.setBusy(integrationKey, true);

    try {
      final result = await _service.integrationAction(
        userId: userId,
        integrationKey: integrationKey,
        action: 'primary',
      );

      if (result.authUrl != null) {
        // handle OAuth redirect
      }

      await load();
    } catch (e) {
      state.value = state.value.setBusy(integrationKey, false);
    }
  }

  void onTapIntegration(BuildContext context, String integrationKey) {
    // navigate to integration detail / manage screen
  }

  void onTapMessages(BuildContext context) {}
  void onTapSettings(BuildContext context) {}
  void onTapHelp(BuildContext context) {}
  void onTapProfile(BuildContext context) {}
  void onTapPciInfo(BuildContext context) {}
  void onTapTrustInfo(BuildContext context) {}
  void onTapStripeInfo(BuildContext context) {}

  void dispose() {
    state.dispose();
  }
}
