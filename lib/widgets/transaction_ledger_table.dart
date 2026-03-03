// transaction_ledger_table.dart
import 'package:flutter/material.dart';

class TransactionLedgerRow {
  final String date;
  final String timeAgo;
  final String actionType;
  final String actor;
  final String dealLead;
  final String fundingSource;
  final double amount;
  final bool isPositive;
  final String outcome;

  TransactionLedgerRow({
    required this.date,
    required this.timeAgo,
    required this.actionType,
    required this.actor,
    required this.dealLead,
    required this.fundingSource,
    required this.amount,
    required this.isPositive,
    required this.outcome,
  });
}

class TransactionLedgerTable extends StatelessWidget {
  final List<TransactionLedgerRow> transactions;
  final String selectedTab;
  final Function(String)? onTabChanged;
  final VoidCallback? onViewFullLedger;

  const TransactionLedgerTable({
    Key? key,
    required this.transactions,
    this.selectedTab = '24H',
    this.onTabChanged,
    this.onViewFullLedger,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'OST Transaction Ledger',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => onTabChanged?.call('24H'),
                    child: _buildTab('24H', selectedTab == '24H'),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onTabChanged?.call('7D'),
                    child: _buildTab('7D', selectedTab == '7D'),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onTabChanged?.call('30D'),
                    child: _buildTab('30D', selectedTab == '30D'),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.more_horiz, color: Colors.white54, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(2),
              5: FlexColumnWidth(1.5),
              6: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                children: [
                  _buildHeaderCell('Date'),
                  _buildHeaderCell('Action Type'),
                  _buildHeaderCell('Actor'),
                  _buildHeaderCell('Deal / Lead'),
                  _buildHeaderCell('Funding Source'),
                  _buildHeaderCell('Amount (OST)'),
                  _buildHeaderCell('Outcome'),
                ],
              ),
              ...transactions.map(_buildDataRow),
            ],
          ),

          const SizedBox(height: 16),
          InkWell(
            onTap: onViewFullLedger,
            child: Row(
              children: const [
                Icon(Icons.add, color: Color(0xFFB8764E), size: 16),
                SizedBox(width: 4),
                Text(
                  'View full ledger',
                  style: TextStyle(
                    color: Color(0xFFB8764E),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2A1810) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFB8764E).withOpacity(0.3)
              : Colors.white10,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white54,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  TableRow _buildDataRow(TransactionLedgerRow transaction) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white10),
        ),
      ),
      children: [
        _buildDataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.date,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                transaction.timeAgo,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
        _buildDataCell(
          Text(
            transaction.actionType,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        _buildDataCell(
          Text(
            transaction.actor,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        _buildDataCell(
          Text(
            transaction.dealLead,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        _buildDataCell(
          Text(
            transaction.fundingSource,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        _buildDataCell(
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: transaction.isPositive
                      ? Colors.green
                      : const Color(0xFFB8764E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${transaction.isPositive ? '+' : ''}${transaction.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildDataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A1810),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFFB8764E).withOpacity(0.3),
              ),
            ),
            child: Text(
              transaction.outcome,
              style: const TextStyle(
                color: Color(0xFFB8764E),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: child,
    );
  }
}
