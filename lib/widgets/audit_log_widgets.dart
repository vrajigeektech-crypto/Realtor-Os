import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class AuditEvent {
  final String timeAgo;
  final String title;
  final String actor;
  final String description;
  final List<String> details;
  final String? badgeLabel;
  final IconData? badgeIcon;
  final Color? badgeColor;

  const AuditEvent({
    required this.timeAgo,
    required this.title,
    required this.actor,
    required this.description,
    this.details = const [],
    this.badgeLabel,
    this.badgeIcon,
    this.badgeColor,
  });
}

class TimelineEventTile extends StatelessWidget {
  const TimelineEventTile({
    super.key,
    required this.event,
    required this.showConnector,
  });

  final AuditEvent event;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineRail(AppStyles.accentRose, AppStyles.borderSoft),
          const SizedBox(width: 12),
          Expanded(
            child: _buildContent(AppStyles.borderSoft, AppStyles.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRail(Color accent, Color border) {
    return Column(
      children: [
        Container(
          width: 14,
          alignment: Alignment.center,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 1.5),
              color: Colors.transparent,
            ),
          ),
        ),
        if (showConnector)
          Container(
            width: 1,
            height: 72,
            margin: const EdgeInsets.only(top: 2),
            color: border,
          ),
      ],
    );
  }

  Widget _buildContent(Color border, Color muted) {
    return Container(
      padding: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade700,
            child: Text(
              event.actor.split(' ').map((e) => e[0]).take(2).join(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.timeAgo,
                  style: TextStyle(color: muted, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: muted, fontSize: 12),
                    children: [
                      TextSpan(
                        text: '${event.actor} ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(text: event.description),
                    ],
                  ),
                ),
                if (event.details.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: event.details
                        .map(
                          (d) => Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file_outlined,
                                size: 12,
                                color: muted,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  d,
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (event.badgeLabel != null) ...[
            const SizedBox(width: 12),
            _AuditBadge(event: event),
          ],
        ],
      ),
    );
  }
}

class _AuditBadge extends StatelessWidget {
  final AuditEvent event;
  const _AuditBadge({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = event.badgeColor ?? AppStyles.accentRose;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color),
        color: color.withValues(alpha: 0.06),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.badgeIcon != null) ...[
            Icon(event.badgeIcon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            event.badgeLabel!,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
