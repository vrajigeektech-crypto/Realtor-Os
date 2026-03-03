import 'package:flutter/material.dart';
import '../widgets/audit_log_widgets.dart';

class TaskAuditHeader {
  final String taskId;
  final String? taskTitle;
  final String? taskDescription;

  TaskAuditHeader({
    required this.taskId,
    this.taskTitle,
    this.taskDescription,
  });

  factory TaskAuditHeader.fromJson(Map<String, dynamic> json) {
    return TaskAuditHeader(
      taskId: json['task_id'] as String? ?? json['taskId'] as String? ?? '',
      taskTitle: json['task_title'] as String? ?? json['taskTitle'] as String?,
      taskDescription: json['task_description'] as String? ?? json['taskDescription'] as String?,
    );
  }
}

class TaskAuditTaskHeader {
  final String taskId;
  final String? agentName;
  final String? agentInitials;
  final String? brokerageName;
  final int? totalTasks;
  final String? joinedDate;

  TaskAuditTaskHeader({
    required this.taskId,
    this.agentName,
    this.agentInitials,
    this.brokerageName,
    this.totalTasks,
    this.joinedDate,
  });

  factory TaskAuditTaskHeader.fromJson(Map<String, dynamic> json) {
    // Extract initials from agent name if available
    String? initials;
    final name = json['agent_name'] as String? ?? json['agentName'] as String?;
    if (name != null && name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.length == 1) {
        initials = parts[0][0].toUpperCase();
      }
    }

    return TaskAuditTaskHeader(
      taskId: json['task_id'] as String? ?? json['taskId'] as String? ?? '',
      agentName: name,
      agentInitials: json['agent_initials'] as String? ?? json['agentInitials'] as String? ?? initials,
      brokerageName: json['brokerage_name'] as String? ?? json['brokerageName'] as String?,
      totalTasks: json['total_tasks'] as int? ?? json['totalTasks'] as int?,
      joinedDate: json['joined_date'] as String? ?? json['joinedDate'] as String?,
    );
  }
}

class TaskAuditEntry {
  final String entryId;
  final String eventType;
  final String? actorName;
  final String? actorInitials;
  final String? actorRole;
  final String? message;
  final String? description;
  final DateTime createdAt;
  final List<AuditAsset> assets;
  final bool? priorityFlag;
  final String? slaOverdueDuration;
  final Map<String, dynamic>? metadata;

  TaskAuditEntry({
    required this.entryId,
    required this.eventType,
    this.actorName,
    this.actorInitials,
    this.actorRole,
    this.message,
    this.description,
    required this.createdAt,
    this.assets = const [],
    this.priorityFlag,
    this.slaOverdueDuration,
    this.metadata,
  });

  factory TaskAuditEntry.fromJson(Map<String, dynamic> json) {
    // Extract initials from actor name if available
    String? initials;
    final actorName = json['actor_name'] as String? ?? json['actorName'] as String?;
    if (actorName != null && actorName.isNotEmpty) {
      final parts = actorName.trim().split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.length == 1) {
        initials = parts[0][0].toUpperCase();
      }
    }

    // Parse assets
    List<AuditAsset> assets = [];
    final assetsData = json['assets'] as List<dynamic>?;
    if (assetsData != null) {
      assets = assetsData
          .map((asset) {
            try {
              if (asset is Map<String, dynamic>) {
                return AuditAsset.fromJson(asset);
              } else if (asset is Map) {
                return AuditAsset.fromJson(Map<String, dynamic>.from(asset));
              }
              return null;
            } catch (e) {
              return null;
            }
          })
          .whereType<AuditAsset>()
          .toList();
    }

    // Parse created_at
    DateTime createdAt;
    final createdAtStr = json['created_at'] as String? ?? json['createdAt'] as String?;
    if (createdAtStr != null) {
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (e) {
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }

    return TaskAuditEntry(
      entryId: json['entry_id'] as String? ?? json['entryId'] as String? ?? '',
      eventType: json['event_type'] as String? ?? json['eventType'] as String? ?? '',
      actorName: actorName,
      actorInitials: json['actor_initials'] as String? ?? json['actorInitials'] as String? ?? initials,
      actorRole: json['actor_role'] as String? ?? json['actorRole'] as String?,
      message: json['message'] as String?,
      description: json['description'] as String?,
      createdAt: createdAt,
      assets: assets,
      priorityFlag: json['priority_flag'] as bool? ?? json['priorityFlag'] as bool?,
      slaOverdueDuration: json['sla_overdue_duration'] as String? ?? json['slaOverdueDuration'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert to AuditEvent for UI
  AuditEvent toAuditEvent() {
    // Map event_type to display title
    String title = _mapEventTypeToTitle(eventType);
    
    // Build description
    String descriptionText = description ?? message ?? '';
    if (actorName != null && descriptionText.isNotEmpty) {
      // Description already includes actor context or we add it
      if (!descriptionText.toLowerCase().startsWith(actorName!.toLowerCase())) {
        descriptionText = descriptionText;
      }
    }

    // Build details from assets
    List<String> details = assets.map((a) => a.fileName ?? a.url ?? 'File').toList();

    // Determine badge
    String? badgeLabel;
    IconData? badgeIcon;
    Color? badgeColor;

    if (assets.isNotEmpty) {
      badgeLabel = '${assets.length} ${assets.length == 1 ? 'File' : 'Files'} uploaded';
      badgeIcon = Icons.cloud_upload_outlined;
      badgeColor = const Color(0xFFCE9799);
    } else if (slaOverdueDuration != null) {
      badgeLabel = slaOverdueDuration!;
      badgeIcon = Icons.warning_amber_outlined;
      badgeColor = Colors.orangeAccent;
    } else if (priorityFlag == true) {
      badgeLabel = 'Priority';
      badgeIcon = Icons.flag_outlined;
      badgeColor = const Color(0xFFCE9799);
    } else if (eventType.toLowerCase().contains('revision')) {
      badgeLabel = 'Revision';
      badgeIcon = Icons.flag_outlined;
      badgeColor = const Color(0xFFCE9799);
    }

    // Format time ago
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    String timeAgo = _formatTimeAgo(difference);

    return AuditEvent(
      timeAgo: timeAgo,
      title: title,
      actor: actorName ?? 'Unknown',
      description: descriptionText,
      details: details,
      badgeLabel: badgeLabel,
      badgeIcon: badgeIcon,
      badgeColor: badgeColor,
    );
  }

  String _mapEventTypeToTitle(String eventType) {
    final type = eventType.toLowerCase();
    if (type.contains('reviewed')) return 'Task Reviewed';
    if (type.contains('paused')) return 'Task Paused';
    if (type.contains('uploaded')) return 'Output Uploaded';
    if (type.contains('status') && type.contains('progress')) return 'Status Set to In Progress';
    if (type.contains('assigned')) return 'Admin Assigned Task';
    if (type.contains('ordered')) return 'Task Ordered';
    if (type.contains('expired') || type.contains('sla')) return 'Task SLA Expired';
    if (type.contains('created')) return 'Task Created';
    if (type.contains('completed')) return 'Task Completed';
    if (type.contains('revision')) return 'Revision Requested';
    
    // Default: capitalize and format
    return eventType
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatTimeAgo(Duration difference) {
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class AuditAsset {
  final String? assetId;
  final String? fileName;
  final String? url;
  final String? fileType;
  final int? fileSize;

  AuditAsset({
    this.assetId,
    this.fileName,
    this.url,
    this.fileType,
    this.fileSize,
  });

  factory AuditAsset.fromJson(Map<String, dynamic> json) {
    return AuditAsset(
      assetId: json['asset_id'] as String? ?? json['assetId'] as String?,
      fileName: json['file_name'] as String? ?? json['fileName'] as String?,
      url: json['url'] as String?,
      fileType: json['file_type'] as String? ?? json['fileType'] as String?,
      fileSize: json['file_size'] as int? ?? json['fileSize'] as int?,
    );
  }
}
