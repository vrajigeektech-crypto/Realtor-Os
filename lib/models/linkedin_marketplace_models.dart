class LinkedInService {
  final String id;
  final String title;
  final String description;
  final String whatThisIs;
  final String whyThisIsShowing;
  final List<String> whatYouGet;
  final String executionType;
  final String format;
  final String posting;
  final String turnaround;
  final String platform;
  final String reuse;
  final int tokenCost;
  final int xpReward;
  final List<String> features;
  final List<String> postTypes;
  final String primaryAction;
  final List<String> secondaryActions;
  final String category;
  final String status;

  LinkedInService({
    required this.id,
    required this.title,
    required this.description,
    required this.whatThisIs,
    required this.whyThisIsShowing,
    required this.whatYouGet,
    required this.executionType,
    required this.format,
    required this.posting,
    required this.turnaround,
    required this.platform,
    required this.reuse,
    required this.tokenCost,
    required this.xpReward,
    required this.features,
    required this.postTypes,
    required this.primaryAction,
    required this.secondaryActions,
    required this.category,
    required this.status,
  });

  factory LinkedInService.fromJson(Map<String, dynamic> json) {
    return LinkedInService(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      whatThisIs: json['whatThisIs'],
      whyThisIsShowing: json['whyThisIsShowing'],
      whatYouGet: List<String>.from(json['whatYouGet'] ?? []),
      executionType: json['executionType'],
      format: json['format'],
      posting: json['posting'],
      turnaround: json['turnaround'],
      platform: json['platform'],
      reuse: json['reuse'],
      tokenCost: json['tokenCost'],
      xpReward: json['xpReward'],
      features: List<String>.from(json['features'] ?? []),
      postTypes: List<String>.from(json['postTypes'] ?? []),
      primaryAction: json['primaryAction'],
      secondaryActions: List<String>.from(json['secondaryActions'] ?? []),
      category: json['category'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'whatThisIs': whatThisIs,
      'whyThisIsShowing': whyThisIsShowing,
      'whatYouGet': whatYouGet,
      'executionType': executionType,
      'format': format,
      'posting': posting,
      'turnaround': turnaround,
      'platform': platform,
      'reuse': reuse,
      'tokenCost': tokenCost,
      'xpReward': xpReward,
      'features': features,
      'postTypes': postTypes,
      'primaryAction': primaryAction,
      'secondaryActions': secondaryActions,
      'category': category,
      'status': status,
    };
  }
}
