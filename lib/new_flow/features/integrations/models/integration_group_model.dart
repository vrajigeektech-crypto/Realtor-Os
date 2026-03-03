import 'integration_model.dart';

class IntegrationGroupModel {
  final String groupKey; // crm | social | payments | automation | storage | google
  final String title;
  final String subtitle;
  final List<IntegrationModel> items;

  const IntegrationGroupModel({
    required this.groupKey,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  factory IntegrationGroupModel.fromJson(Map<String, dynamic> json) {
    return IntegrationGroupModel(
      groupKey: json['group_key'] as String,
      title: json['group_title'] as String,
      subtitle: json['group_subtitle'] as String? ?? '',
      items: (json['items'] as List<dynamic>)
          .map(
            (e) => IntegrationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  IntegrationGroupModel copyWith({
    String? title,
    String? subtitle,
    List<IntegrationModel>? items,
  }) {
    return IntegrationGroupModel(
      groupKey: groupKey,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      items: items ?? this.items,
    );
  }
}
