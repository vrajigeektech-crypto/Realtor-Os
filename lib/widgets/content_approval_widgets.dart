import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

enum ApprovalStatusType { neutral, positiveLocked, neutralLocked, pending }

class ApprovalRowData {
  final String title;
  final String lastActionAgo;
  final String statusLabel;
  final ApprovalStatusType statusType;
  final String actionLabel;
  final String? actionSecondary;
  final bool isRevision;
  final String? mediaType; // 'video' or 'document' or null
  final String? itemId; // For tracking which item to send reminder for

  const ApprovalRowData({
    required this.title,
    required this.lastActionAgo,
    required this.statusLabel,
    required this.statusType,
    required this.actionLabel,
    this.actionSecondary,
    this.isRevision = false,
    this.mediaType,
    this.itemId,
  });
}

class ContentApprovalRow extends StatelessWidget {
  final ApprovalRowData row;
  final VoidCallback? onSendReminder;
  final bool isLoading;
  final bool isReminderSent;
  
  const ContentApprovalRow({
    super.key,
    required this.row,
    this.onSendReminder,
    this.isLoading = false,
    this.isReminderSent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // MainLayout bg
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 18,
            color: AppStyles.mutedText,
          ),
          const SizedBox(width: 14),
          _Thumbnail(isRevision: row.isRevision),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (row.isRevision)
                  const Text(
                    'Revision Requested',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (row.isRevision) const SizedBox(height: 2),
                Text(
                  row.title,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              row.lastActionAgo,
              style: const TextStyle(color: AppStyles.mutedText, fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _StatusPill(row: row)),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SecondaryActionButton(
                  label: isReminderSent ? 'Reminder Sent' : row.actionLabel,
                  icon: row.actionLabel.startsWith('Respond')
                      ? Icons.reply_outlined
                      : Icons.notifications_none_outlined,
                  filled:
                      row.actionLabel.startsWith('Respond') ||
                      row.actionLabel.startsWith('Approved') ||
                      isReminderSent,
                  onPressed: isReminderSent ? null : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Action: ${row.actionLabel}')),
                    );
                  },
                  isLoading: isLoading && !isReminderSent,
                  isDisabled: isReminderSent,
                ),
                if (row.actionSecondary != null && !isReminderSent) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        row.actionSecondary!.startsWith('Send')
                            ? Icons.notifications_active_outlined
                            : Icons.info_outline,
                        color: AppStyles.mutedText,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onSendReminder != null && !isLoading ? onSendReminder : null,
                        child: Text(
                          row.actionSecondary!,
                          style: TextStyle(
                            color: onSendReminder != null && !isLoading
                                ? AppStyles.accentRose
                                : AppStyles.mutedText,
                            fontSize: 11,
                            decoration: onSendReminder != null && !isLoading
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContentApprovalMobileCard extends StatelessWidget {
  final ApprovalRowData row;
  final VoidCallback? onSendReminder;
  final bool isLoading;
  final bool isReminderSent;
  
  const ContentApprovalMobileCard({
    super.key,
    required this.row,
    this.onSendReminder,
    this.isLoading = false,
    this.isReminderSent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyles.panelColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppStyles.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(isRevision: row.isRevision, mediaType: row.mediaType),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (row.isRevision)
                      const Text(
                        'Revision Requested',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Text(
                      row.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      row.lastActionAgo,
                      style: const TextStyle(
                        color: AppStyles.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(row: row),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _SecondaryActionButton(
                  label: isReminderSent ? 'Reminder Sent' : row.actionLabel,
                  icon: row.actionLabel.startsWith('Respond')
                      ? Icons.reply_outlined
                      : Icons.notifications_none_outlined,
                  filled: true,
                  onPressed: isReminderSent
                      ? null
                      : (onSendReminder != null && row.actionSecondary?.toLowerCase().contains('reminder') == true
                          ? onSendReminder
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Action: ${row.actionLabel}')),
                              );
                            }),
                  isLoading: isLoading && !isReminderSent,
                  isDisabled: isReminderSent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Helpers ---

class _Thumbnail extends StatelessWidget {
  final bool isRevision;
  final String? mediaType; // 'video' or 'document' or null
  const _Thumbnail({required this.isRevision, this.mediaType});

  @override
  Widget build(BuildContext context) {
    // Determine icon based on media type or revision status
    final bool isVideo = mediaType?.toLowerCase() == 'video';
    final bool isDocument = mediaType?.toLowerCase() == 'document' || isRevision;
    
    return Container(
      width: 72,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppStyles.borderSoft),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Stack(
        children: [
          if (isVideo)
            const Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white70,
                size: 28,
              ),
            )
          else if (isDocument)
            const Center(
              child: Icon(
                Icons.description_outlined,
                color: Colors.white70,
                size: 22,
              ),
            )
          else
            const Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white70,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final ApprovalRowData row;
  const _StatusPill({required this.row});

  @override
  Widget build(BuildContext context) {
    Color border;
    Color textColor;
    Color bg;

    switch (row.statusType) {
      case ApprovalStatusType.positiveLocked:
        border = AppStyles.accentRose;
        textColor = Colors.white;
        bg = AppStyles.accentRose.withValues(alpha: 0.18);
        break;
      case ApprovalStatusType.neutralLocked:
        border = AppStyles.borderSoft;
        textColor = Colors.white;
        bg = const Color(0xFF232329);
        break;
      case ApprovalStatusType.pending:
        border = AppStyles.accentRose;
        textColor = AppStyles.accentRose;
        bg = Colors.transparent;
        break;
      case ApprovalStatusType.neutral:
        border = AppStyles.borderSoft;
        textColor = Colors.white;
        bg = Colors.transparent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
        color: bg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (row.statusType == ApprovalStatusType.positiveLocked ||
              row.statusType == ApprovalStatusType.neutralLocked) ...[
            const Icon(Icons.lock, size: 14, color: AppStyles.mutedText),
            const SizedBox(width: 6),
          ],
          Text(
            row.statusLabel,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    this.filled = false,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = this.isDisabled || isLoading;
    
    if (filled) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.white10.withValues(alpha: 0.3) : Colors.white10,
          foregroundColor: isDisabled ? AppStyles.mutedText : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
        onPressed: isDisabled ? null : (onPressed ?? () {}),
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 11.5)),
      );
    }
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isDisabled ? AppStyles.borderSoft.withValues(alpha: 0.3) : AppStyles.borderSoft,
        ),
        foregroundColor: isDisabled ? AppStyles.mutedText.withValues(alpha: 0.5) : AppStyles.mutedText,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: isDisabled ? null : (onPressed ?? () {}),
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF888888)),
              ),
            )
          : Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 11.5)),
    );
  }
}
