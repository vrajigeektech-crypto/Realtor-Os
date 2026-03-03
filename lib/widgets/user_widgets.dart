import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class UserRowData {
  const UserRowData({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastLogin,
    required this.totalOrders,
    required this.tokenBalance,
    required this.hasFlags,
  });

  final String name;
  final String email;
  final String role;
  final String status;
  final String lastLogin;
  final String totalOrders;
  final String tokenBalance;
  final bool hasFlags;
}

class UserTableRow extends StatelessWidget {
  const UserTableRow({super.key, required this.row, this.selected = false});

  final UserRowData row;
  final bool selected;

  Color get statusColor =>
      row.status == 'Active' ? AppStyles.statusGreen : AppStyles.statusYellow;

  static int flexForIndex(int i) {
    switch (i) {
      case 0:
        return 3; // name
      case 1:
        return 4; // email
      case 2:
        return 2; // role
      case 3:
        return 2; // status
      case 4:
        return 3; // last login
      case 5:
        return 2; // total orders
      case 6:
        return 2; // token balance
      case 7:
        return 2; // flags
      case 8:
        return 1; // actions
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    const mutedText = AppStyles.mutedText;

    return Container(
      color: selected ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _cell(
            Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: const Color(0xFF3F4651),
                  child: Text(
                    row.name.isNotEmpty ? row.name[0] : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    row.name,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            flex: flexForIndex(0),
          ),
          _cell(
            Text(
              row.email,
              style: const TextStyle(color: mutedText, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            flex: flexForIndex(1),
          ),
          _cell(
            Text(
              row.role,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            flex: flexForIndex(2),
          ),
          _cell(
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  row.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            flex: flexForIndex(3),
          ),
          _cell(
            Text(
              row.lastLogin,
              style: const TextStyle(color: mutedText, fontSize: 12),
            ),
            flex: flexForIndex(4),
          ),
          _cell(
            Text(
              row.totalOrders,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            flex: flexForIndex(5),
          ),
          _cell(
            Text(
              row.tokenBalance,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            flex: flexForIndex(6),
          ),
          _cell(
            row.hasFlags
                ? const Icon(Icons.flag, color: Colors.amber, size: 16)
                : const SizedBox.shrink(),
            flex: flexForIndex(7),
          ),
          _cell(
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.search, color: mutedText, size: 16),
                SizedBox(width: 10),
                Icon(Icons.lock_outline, color: mutedText, size: 15),
                SizedBox(width: 10),
                Icon(Icons.more_horiz, color: mutedText, size: 18),
              ],
            ),
            flex: flexForIndex(8),
          ),
        ],
      ),
    );
  }

  Widget _cell(Widget child, {required int flex}) => Expanded(
    flex: flex,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: child,
    ),
  );
}

class UserMobileCard extends StatelessWidget {
  final UserRowData row;
  const UserMobileCard({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    final statusColor = row.status == 'Active'
        ? AppStyles.statusGreen
        : AppStyles.statusYellow;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF3F4651),
                child: Text(
                  row.name.isNotEmpty ? row.name[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
                      row.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      row.email,
                      style: const TextStyle(
                        color: AppStyles.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  row.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppStyles.borderSoft, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoPair(label: 'Role', value: row.role),
              _InfoPair(label: 'Total Orders', value: row.totalOrders),
              _InfoPair(label: 'Tokens', value: row.tokenBalance),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoPair(label: 'Last Login', value: row.lastLogin),
              if (row.hasFlags)
                const Icon(Icons.flag, color: Colors.amber, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPair extends StatelessWidget {
  final String label;
  final String value;
  const _InfoPair({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppStyles.mutedText, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
