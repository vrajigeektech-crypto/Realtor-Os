import 'package:flutter/foundation.dart';

import 'speed_to_lead_state_model.dart';
import 'speed_to_lead_metric_model.dart';
import 'lead_arrival_model.dart';

class SpeedToLeadActivationController extends ChangeNotifier {
  SpeedToLeadActivationController({
    required SpeedToLeadStateModel initialState,
  }) : _state = initialState;

  SpeedToLeadStateModel _state;
  SpeedToLeadStateModel get state => _state;

  void setLoading(bool value) {
    _state = _state.copyWith(isLoading: value);
    notifyListeners();
  }

  void setHeader({
    required String title,
    required String subtitle,
  }) {
    _state = _state.copyWith(
      title: title,
      subtitle: subtitle,
    );
    notifyListeners();
  }

  void setMetrics(List<SpeedToLeadMetricModel> metrics) {
    _state = _state.copyWith(metrics: metrics);
    notifyListeners();
  }

  void setLatestLead(LeadArrivalModel? lead) {
    _state = _state.copyWith(latestLead: lead);
    notifyListeners();
  }

  void setCtas({
    required String primaryLabel,
    required String secondaryLabel,
    required bool primaryEnabled,
    required bool secondaryEnabled,
  }) {
    _state = _state.copyWith(
      primaryCtaLabel: primaryLabel,
      secondaryCtaLabel: secondaryLabel,
      primaryEnabled: primaryEnabled,
      secondaryEnabled: secondaryEnabled,
    );
    notifyListeners();
  }

  void setBottomNote(String note) {
    _state = _state.copyWith(bottomNote: note);
    notifyListeners();
  }
}
