import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/social_media_integrations_repository.dart';
import '../models/social_integration_model.dart';
import 'social_media_integrations_state.dart';

class SocialMediaIntegrationsController extends ChangeNotifier {
  SocialMediaIntegrationsController({
    required SocialMediaIntegrationsRepository repository,
  }) : _repository = repository;

  final SocialMediaIntegrationsRepository _repository;

  SocialMediaIntegrationsState _state = const SocialMediaIntegrationsState.initial();
  SocialMediaIntegrationsState get state => _state;

  Timer? _debounce;

  void disposeDebounce() {
    _debounce?.cancel();
    _debounce = null;
  }

  @override
  void dispose() {
    disposeDebounce();
    super.dispose();
  }

  Future<void> load({required String userId, bool forceRefresh = false}) async {
    _setState(_state.copyWith(userId: userId, isLoading: true, error: null));

    try {
      final integrations = await _repository.fetchIntegrations(userId: userId);
      
      final items = integrations.map((model) => SocialIntegrationItem(
        integrationKey: model.integrationKey,
        displayName: model.displayName,
        group: model.group,
        connected: model.connected,
        lastSyncedAt: model.lastSyncedAt,
      )).toList();

      _setState(
        _state.copyWith(
          isLoading: false,
          headerTitle: 'Social Media Integrations',
          headerSubtitle: 'Link your social media accounts.',
          items: items,
          error: null,
          lastRefreshedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      _setState(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> connect({
    required String userId,
    required String integrationKey,
  }) async {
    _setState(_state.copyWith(isMutating: true, error: null));

    try {
      await _repository.connectIntegration(
        userId: userId,
        integrationKey: integrationKey,
      );

      // Update the specific item in the list
      final updatedItems = _state.items.map((item) {
        if (item.integrationKey == integrationKey) {
          return item.copyWith(connected: true, lastSyncedAt: DateTime.now());
        }
        return item;
      }).toList();

      _setState(_state.copyWith(
        isMutating: false,
        items: updatedItems,
      ));
    } catch (e) {
      _setState(_state.copyWith(isMutating: false, error: e.toString()));
    }
  }

  Future<void> disconnect({
    required String userId,
    required String integrationKey,
  }) async {
    _setState(_state.copyWith(isMutating: true, error: null));

    try {
      await _repository.disconnectIntegration(
        userId: userId,
        integrationKey: integrationKey,
      );

      // Update the specific item in the list
      final updatedItems = _state.items.map((item) {
        if (item.integrationKey == integrationKey) {
          return item.copyWith(connected: false);
        }
        return item;
      }).toList();

      _setState(_state.copyWith(
        isMutating: false,
        items: updatedItems,
      ));
    } catch (e) {
      _setState(_state.copyWith(isMutating: false, error: e.toString()));
    }
  }

  void setSearchQuery(String value) {
    _setState(_state.copyWith(searchQuery: value));

    disposeDebounce();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      notifyListeners();
    });
  }

  void setFilterPlatformGroup(String value) {
    _setState(_state.copyWith(platformGroup: value));
  }

  void onTapIntegration(String integrationKey) {
    _setState(_state.copyWith(selectedIntegrationKey: integrationKey));
  }

  void clearSelectedIntegration() {
    _setState(_state.copyWith(selectedIntegrationKey: null));
  }

  void _setState(SocialMediaIntegrationsState next) {
    _state = next;
    notifyListeners();
  }
}
