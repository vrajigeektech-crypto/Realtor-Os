/// Task detail model from RPC: view_task_detail
/// RPC Output: { id, user_id, title, description, category, status, token_cost, xp_reward, created_at, updated_at }
class TaskDetail {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String status;
  final int tokenCost;
  final int xpReward;
  final String createdAt;
  final String updatedAt;

  TaskDetail({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.tokenCost,
    required this.xpReward,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskDetail.fromRpcJson(Map<String, dynamic> json) {
    // Safely handle all fields that might be null
    return TaskDetail(
      id: (json['id'] as String?)?.toString() ?? '',
      userId: (json['user_id'] as String?)?.toString() ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      tokenCost: (json['token_cost'] as num?)?.toInt() ?? 0,
      xpReward: (json['xp_reward'] as num?)?.toInt() ?? 0,
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: (json['updated_at'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'token_cost': tokenCost,
      'xp_reward': xpReward,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
