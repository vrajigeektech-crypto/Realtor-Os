class PromotionItem {
  final String id;
  final String title;
  final String description;
  final int tokenCost;
  final String category;
  final String icon;
  final List<String> tags;
  final int popularityScore;
  final bool isFeatured;

  PromotionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.tokenCost,
    required this.category,
    required this.icon,
    this.tags = const [],
    this.popularityScore = 0,
    this.isFeatured = false,
  });

  factory PromotionItem.fromJson(Map<String, dynamic> json) {
    return PromotionItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      tokenCost: json['token_cost'],
      category: json['category'],
      icon: json['icon'],
      tags: List<String>.from(json['tags'] ?? []),
      popularityScore: json['popularity_score'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'token_cost': tokenCost,
      'category': category,
      'icon': icon,
      'tags': tags,
      'popularity_score': popularityScore,
      'is_featured': isFeatured,
    };
  }
}

class QueueItem {
  final String id;
  final String promotionId;
  final String promotionTitle;
  final int tokensDeducted;
  final DateTime queuedAt;
  final String status; // 'scheduled', 'processing', 'completed', 'failed'
  final String? propertyId;
  final Map<String, dynamic>? metadata;

  QueueItem({
    required this.id,
    required this.promotionId,
    required this.promotionTitle,
    required this.tokensDeducted,
    required this.queuedAt,
    this.status = 'scheduled',
    this.propertyId,
    this.metadata,
  });

  factory QueueItem.fromJson(Map<String, dynamic> json) {
    return QueueItem(
      id: json['id'],
      promotionId: json['promotion_id'],
      promotionTitle: json['promotion_title'],
      tokensDeducted: json['tokens_deducted'],
      queuedAt: DateTime.parse(json['queued_at']),
      status: json['status'] ?? 'scheduled',
      propertyId: json['property_id'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promotion_id': promotionId,
      'promotion_title': promotionTitle,
      'tokens_deducted': tokensDeducted,
      'queued_at': queuedAt.toIso8601String(),
      'status': status,
      'property_id': propertyId,
      'metadata': metadata,
    };
  }
}

class RecommendationLogic {
  final List<PromotionItem> availableItems;
  final List<String> previouslyPurchased;
  final List<String> activeInQueue;

  RecommendationLogic({
    required this.availableItems,
    this.previouslyPurchased = const [],
    this.activeInQueue = const [],
  });

  List<PromotionItem> getRecommendations({int limit = 6}) {
    // Filter out items already in queue
    final filteredItems = availableItems.where((item) => 
      !activeInQueue.contains(item.id)
    ).toList();

    // Shuffle for randomness
    final shuffled = List<PromotionItem>.from(filteredItems)..shuffle();

    // Prioritize items that feel "smart"
    final prioritized = <PromotionItem>[];
    
    // Add some previously purchased items (repeat upsell)
    final repeatItems = shuffled.where((item) => 
      previouslyPurchased.contains(item.id)
    ).take(2);
    prioritized.addAll(repeatItems);

    // Add high-profit items
    final highProfitItems = shuffled.where((item) => 
      item.tokenCost >= 15 && !prioritized.contains(item)
    ).take(2);
    prioritized.addAll(highProfitItems);

    // Add featured items
    final featuredItems = shuffled.where((item) => 
      item.isFeatured && !prioritized.contains(item)
    ).take(1);
    prioritized.addAll(featuredItems);

    // Fill remaining slots with random items
    final remaining = shuffled.where((item) => 
      !prioritized.contains(item)
    ).take(limit - prioritized.length);
    prioritized.addAll(remaining);

    return prioritized.take(limit).toList();
  }

  PromotionItem? getTopPick() {
    final recommendations = getRecommendations(limit: 1);
    return recommendations.isNotEmpty ? recommendations.first : null;
  }

  String getRecommendationReason(PromotionItem item) {
    final reasons = [
      "Recommended for this property",
      "Boost visibility by 3x",
      "Most agents choose this",
      "Based on your last listing",
      "Trending in your area",
      "High conversion rate",
      "Perfect for this price range",
    ];
    
    if (item.isFeatured) {
      return reasons[0]; // "Recommended for this property"
    }
    
    if (previouslyPurchased.contains(item.id)) {
      return "You used this before";
    }
    
    if (item.tokenCost >= 15) {
      return "Premium option";
    }
    
    return reasons[(item.id.hashCode % reasons.length)];
  }
}
