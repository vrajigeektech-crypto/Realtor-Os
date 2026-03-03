import 'speed_to_lead_metric_model.dart';
import 'lead_arrival_model.dart';

class SpeedToLeadStateModel {
  final String title;
  final String subtitle;
  final String bottomNote;

  final List<SpeedToLeadMetricModel> metrics;
  final LeadArrivalModel? latestLead;

  final String primaryCtaLabel;
  final String secondaryCtaLabel;
  final bool primaryEnabled;
  final bool secondaryEnabled;

  final bool isLoading;

  const SpeedToLeadStateModel({
    required this.title,
    required this.subtitle,
    required this.bottomNote,
    required this.metrics,
    required this.latestLead,
    required this.primaryCtaLabel,
    required this.secondaryCtaLabel,
    required this.primaryEnabled,
    required this.secondaryEnabled,
    required this.isLoading,
  });

  SpeedToLeadStateModel copyWith({
    String? title,
    String? subtitle,
    String? bottomNote,
    List<SpeedToLeadMetricModel>? metrics,
    LeadArrivalModel? latestLead,
    String? primaryCtaLabel,
    String? secondaryCtaLabel,
    bool? primaryEnabled,
    bool? secondaryEnabled,
    bool? isLoading,
  }) {
    return SpeedToLeadStateModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      bottomNote: bottomNote ?? this.bottomNote,
      metrics: metrics ?? this.metrics,
      latestLead: latestLead ?? this.latestLead,
      primaryCtaLabel: primaryCtaLabel ?? this.primaryCtaLabel,
      secondaryCtaLabel: secondaryCtaLabel ?? this.secondaryCtaLabel,
      primaryEnabled: primaryEnabled ?? this.primaryEnabled,
      secondaryEnabled: secondaryEnabled ?? this.secondaryEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory SpeedToLeadStateModel.initial() {
    return const SpeedToLeadStateModel(
      title: '',
      subtitle: '',
      bottomNote: '',
      metrics: [],
      latestLead: null,
      primaryCtaLabel: '',
      secondaryCtaLabel: '',
      primaryEnabled: false,
      secondaryEnabled: false,
      isLoading: true,
    );
  }
}
