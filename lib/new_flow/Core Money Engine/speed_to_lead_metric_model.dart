import 'speed_to_lead_metric_key.dart';

class SpeedToLeadMetricModel {
  final String id;
  final SpeedToLeadMetricKey metricKey;
  final String value;
  final String label;

  const SpeedToLeadMetricModel({
    required this.id,
    required this.metricKey,
    required this.value,
    required this.label,
  });

  factory SpeedToLeadMetricModel.fromJson(Map<String, dynamic> json) {
    return SpeedToLeadMetricModel(
      id: json['id'] as String,
      metricKey:
          SpeedToLeadMetricKey.fromString(json['metric_key'] as String),
      value: json['value'] as String,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metric_key': metricKey.key,
      'value': value,
      'label': label,
    };
  }
}
