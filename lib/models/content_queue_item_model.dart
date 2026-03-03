class ContentQueueItemModel {
  final String itemId;
  final String title;
  final String? subtitle;
  final ContentMedia? media;
  final String statusLabel;
  final String statusKey;
  final String primaryActionLabel;
  final String primaryActionType;
  final bool isActionDisabled;

  ContentQueueItemModel({
    required this.itemId,
    required this.title,
    this.subtitle,
    this.media,
    required this.statusLabel,
    required this.statusKey,
    required this.primaryActionLabel,
    required this.primaryActionType,
    required this.isActionDisabled,
  });

  factory ContentQueueItemModel.fromJson(Map<String, dynamic> json) {
    return ContentQueueItemModel(
      itemId: json['item_id'] as String? ?? json['itemId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      media: json['media'] != null
          ? ContentMedia.fromJson(
              json['media'] is Map
                  ? json['media'] as Map<String, dynamic>
                  : Map<String, dynamic>.from(json['media']),
            )
          : null,
      statusLabel: json['status_label'] as String? ?? json['statusLabel'] as String? ?? '',
      statusKey: json['status_key'] as String? ?? json['statusKey'] as String? ?? '',
      primaryActionLabel: json['primary_action_label'] as String? ?? json['primaryActionLabel'] as String? ?? '',
      primaryActionType: json['primary_action_type'] as String? ?? json['primaryActionType'] as String? ?? '',
      isActionDisabled: json['is_action_disabled'] as bool? ?? json['isActionDisabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'title': title,
      'subtitle': subtitle,
      'media': media?.toJson(),
      'status_label': statusLabel,
      'status_key': statusKey,
      'primary_action_label': primaryActionLabel,
      'primary_action_type': primaryActionType,
      'is_action_disabled': isActionDisabled,
    };
  }
}

class ContentMedia {
  final String type; // 'video' or 'document'
  final String? thumbnailUrl;
  final String? streamUrl;

  ContentMedia({
    required this.type,
    this.thumbnailUrl,
    this.streamUrl,
  });

  factory ContentMedia.fromJson(Map<String, dynamic> json) {
    return ContentMedia(
      type: json['type'] as String? ?? 'document',
      thumbnailUrl: json['thumbnail_url'] as String? ?? json['thumbnailUrl'] as String?,
      streamUrl: json['stream_url'] as String? ?? json['streamUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'thumbnail_url': thumbnailUrl,
      'stream_url': streamUrl,
    };
  }
}
