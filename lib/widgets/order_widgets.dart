import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

enum StatusType { pending, inReview, inProgress, completed, blocked, overdue }

class OrderRowData {
  const OrderRowData({
    required this.id,
    required this.agent,
    required this.brokerage,
    required this.product,
    required this.status,
    required this.statusType,
    required this.admin,
    required this.created,
    required this.sla,
  });

  final String id;
  final String agent;
  final String brokerage;
  final String product;
  final String status;
  final StatusType statusType;
  final String admin;
  final String created;
  final String sla;
}

class OrderTableRow extends StatelessWidget {
  const OrderTableRow({super.key, required this.row});

  final OrderRowData row;

  Color _badgeColor() {
    switch (row.statusType) {
      case StatusType.pending:
        return AppStyles.statusYellow;
      case StatusType.inReview:
        return Colors.deepOrangeAccent;
      case StatusType.inProgress:
        return AppStyles.statusGreen;
      case StatusType.completed:
        return Colors.blueGrey;
      case StatusType.blocked:
        return AppStyles.statusRed;
      case StatusType.overdue:
        return AppStyles.statusRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget cell(Widget child, {int flex = 1}) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: child,
      ),
    );

    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          cell(
            Text(
              row.id,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            flex: 2,
          ),
          cell(
            Text(
              row.agent,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            flex: 3,
          ),
          cell(
            Text(
              row.brokerage,
              style: const TextStyle(color: AppStyles.mutedText, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            flex: 3,
          ),
          cell(
            Text(
              row.product,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            flex: 3,
          ),
          cell(
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _badgeColor().withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _badgeColor()),
                ),
                child: Text(
                  row.status,
                  style: TextStyle(
                    color: _badgeColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            flex: 2,
          ),
          cell(
            Text(
              row.admin,
              style: const TextStyle(color: AppStyles.mutedText, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            flex: 3,
          ),
          cell(
            Text(
              row.created,
              style: const TextStyle(color: AppStyles.mutedText, fontSize: 12),
            ),
            flex: 2,
          ),
          cell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                row.sla,
                style: TextStyle(
                  color: row.statusType == StatusType.overdue
                      ? AppStyles.statusRed
                      : Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            flex: 2,
          ),
          cell(
            Center(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppStyles.borderSoft),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
                onPressed: () {},
                child: const Text('View'),
              ),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }
}

class OrderMobileCard extends StatelessWidget {
  final OrderRowData row;
  const OrderMobileCard({super.key, required this.row});

  Color _badgeColor() {
    switch (row.statusType) {
      case StatusType.pending:
        return AppStyles.statusYellow;
      case StatusType.inReview:
        return Colors.deepOrangeAccent;
      case StatusType.inProgress:
        return AppStyles.statusGreen;
      case StatusType.completed:
        return Colors.blueGrey;
      case StatusType.blocked:
        return AppStyles.statusRed;
      case StatusType.overdue:
        return AppStyles.statusRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppStyles.panelColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppStyles.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                row.id,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _badgeColor().withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _badgeColor()),
                ),
                child: Text(
                  row.status,
                  style: TextStyle(
                    color: _badgeColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: AppStyles.mutedText),
              const SizedBox(width: 6),
              Text(
                row.agent,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            row.product,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Divider(color: AppStyles.borderSoft, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Due: ${row.sla}',
                style: const TextStyle(
                  color: AppStyles.mutedText,
                  fontSize: 12,
                ),
              ),
              SizedBox(
                height: 32,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppStyles.borderSoft),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'View Detail',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --------- Details pane helpers ---------

class DetailsSectionTitle extends StatelessWidget {
  const DetailsSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppStyles.mutedText,
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}

class ChecklistItem extends StatelessWidget {
  const ChecklistItem(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_box, size: 14, color: AppStyles.statusGreen),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}

class BulletLine extends StatelessWidget {
  const BulletLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(color: AppStyles.mutedText, fontSize: 12),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 11.5),
          ),
        ),
      ],
    );
  }
}
