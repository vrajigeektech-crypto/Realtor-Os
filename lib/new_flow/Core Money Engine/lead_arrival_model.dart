class LeadArrivalModel {
  final String leadId;
  final String name;
  final String source;
  final String phone;
  final String email;
  final String receivedAtLabel;

  const LeadArrivalModel({
    required this.leadId,
    required this.name,
    required this.source,
    required this.phone,
    required this.email,
    required this.receivedAtLabel,
  });

  factory LeadArrivalModel.fromJson(Map<String, dynamic> json) {
    return LeadArrivalModel(
      leadId: json['lead_id'] as String,
      name: json['name'] as String,
      source: json['source'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      receivedAtLabel: json['received_at_label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lead_id': leadId,
      'name': name,
      'source': source,
      'phone': phone,
      'email': email,
      'received_at_label': receivedAtLabel,
    };
  }
}
