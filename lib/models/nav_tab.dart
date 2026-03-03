/// Navigation tab model from RPC: get_agent_nav_tabs
/// RPC Output: [{ id, label }]
class NavTab {
  final String id;
  final String label;

  NavTab({
    required this.id,
    required this.label,
  });

  factory NavTab.fromRpcJson(Map<String, dynamic> json) {
    return NavTab(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
    };
  }
}
