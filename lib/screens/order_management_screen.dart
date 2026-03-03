import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import '../utils/app_styles.dart';
import '../widgets/order_widgets.dart';

/// Realtor OS – Order Management Screen
/// Responsive: Mobile Card List vs Desktop Split View.
class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Order Management',
      activeIndex: 8, // Admin/Task
      child: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 900;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(isMobile),
                    const Divider(height: 0, color: AppStyles.borderSoft),
                    Expanded(
                      child: isMobile
                          ? _buildMobileLayout()
                          : Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildOrdersPane(false),
                                ),
                                const VerticalDivider(
                                  width: 0,
                                  color: AppStyles.borderSoft,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _buildOrderDetailsPane(),
                                ),
                              ],
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 14,
      ),
      color: Colors.transparent,
      child: Row(
        children: [
          const Text(
            'Order Management',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (!isMobile)
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppStyles.borderSoft),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: AppStyles.mutedText, size: 17),
                  SizedBox(width: 6),
                  Text(
                    'Search orders…',
                    style: TextStyle(
                      color: AppStyles.mutedText,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(children: [Expanded(child: _buildOrdersPane(true))]);
  }

  Widget _buildOrdersPane(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFiltersRow(isMobile),
        const Divider(height: 0, color: AppStyles.borderSoft),
        Expanded(child: isMobile ? _buildMobileList() : _buildOrdersTable()),
      ],
    );
  }

  Widget _buildFiltersRow(bool isMobile) {
    Widget filterDropdown(String label) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 32,
        decoration: BoxDecoration(
          color: AppStyles.panelColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppStyles.borderSoft),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(color: AppStyles.mutedText, fontSize: 12),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppStyles.mutedText,
              size: 18,
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  filterDropdown('Status'),
                  const SizedBox(width: 8),
                  if (!isMobile) ...[
                    filterDropdown('Product / SKU'),
                    const SizedBox(width: 8),
                    filterDropdown('Assigned Admin'),
                    const SizedBox(width: 8),
                  ],
                  filterDropdown('More Filters'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  // --- Desktop Table ---
  Widget _buildOrdersTable() {
    final rows = _fakeOrders;
    return Container(
      color: AppStyles.panelColor.withValues(alpha: 0.0), // Transparent
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableHeader(),
          const Divider(height: 0, color: AppStyles.borderSoft),
          Expanded(
            child: ListView.separated(
              itemCount: rows.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 0, color: AppStyles.borderSoft),
              itemBuilder: (context, index) {
                final row = rows[index];
                return OrderTableRow(row: row);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Mobile ListView ---
  Widget _buildMobileList() {
    final rows = _fakeOrders;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return OrderMobileCard(row: row);
      },
    );
  }

  Widget _buildTableHeader() {
    const headerStyle = TextStyle(
      color: AppStyles.mutedText,
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
    );
    Widget cell(
      String text, {
      int flex = 1,
      TextAlign align = TextAlign.left,
    }) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(text, style: headerStyle, textAlign: align),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white10,
      child: Row(
        children: [
          cell('Order ID', flex: 2),
          cell('Agent', flex: 3),
          cell('Brokerage', flex: 3),
          cell('Product / SKU', flex: 3),
          cell('Status', flex: 2),
          cell('Assigned', flex: 3),
          cell('Created', flex: 2),
          cell('Due', flex: 2, align: TextAlign.right),
          cell('Actions', flex: 2, align: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsPane() {
    return Container(
      color: AppStyles.darkBackground,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Order Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _buildSelectedOrderHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  DetailsSectionTitle('Order Summary'),
                  SizedBox(height: 6),
                  SummaryRow(label: 'Product', value: 'Social Media Kit'),
                  SummaryRow(label: 'SKU', value: 'SMK-002'),
                  SummaryRow(label: 'Created', value: '11/18/2021'),
                  SummaryRow(label: 'Due Date', value: '11/20/2021'),
                  SizedBox(height: 14),
                  DetailsSectionTitle('Inputs Received'),
                  SizedBox(height: 6),
                  ChecklistItem('Photos Received'),
                  ChecklistItem('Property Details Provided'),
                  ChecklistItem('Branding Guidelines Submitted'),
                  SizedBox(height: 14),
                  DetailsSectionTitle('Blockers'),
                  SizedBox(height: 6),
                  BulletLine('Waiting on updated client feedback'),
                  SizedBox(height: 14),
                  DetailsSectionTitle('Internal Notes'),
                  SizedBox(height: 6),
                  BulletLine(
                    'Client has requested revisions. Awaiting new assets from the agent.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedOrderHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppStyles.panelColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppStyles.borderSoft),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF404854),
            child: Text(
              'SC',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Order #10456',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Agent: Sarah Collins',
                  style: TextStyle(color: AppStyles.mutedText, fontSize: 12),
                ),
                SizedBox(height: 2),
                Text(
                  'Keller Williams Realty',
                  style: TextStyle(color: AppStyles.mutedText, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Fake data for static mock
const _fakeOrders = <OrderRowData>[
  OrderRowData(
    id: '#053008',
    agent: 'Dyare Brooks',
    brokerage: '666, Getexy',
    product: 'SEM / iHomects',
    status: 'Pending',
    statusType: StatusType.pending,
    admin: 'Lee Myers',
    created: '02/16/2021',
    sla: '2h 15m',
  ),
  OrderRowData(
    id: '#034079',
    agent: 'Selly Smith',
    brokerage: '206, Provision',
    product: 'Pact Pro',
    status: 'In Review',
    statusType: StatusType.inReview,
    admin: 'Jett Dillons',
    created: '06/16/2021',
    sla: '8h 20m',
  ),
  OrderRowData(
    id: '#033003',
    agent: 'Sra Algar',
    brokerage: '022, Arden Wessed',
    product: 'Starting Optimum',
    status: 'In Progress',
    statusType: StatusType.inProgress,
    admin: 'Dob Bower',
    created: '02/16/2021',
    sla: '3h 4h',
  ),
  OrderRowData(
    id: '#030169',
    agent: 'John Remall',
    brokerage: '306, Asgercho',
    product: 'BBX Summame',
    status: 'In Progress',
    statusType: StatusType.inProgress,
    admin: 'Tom Tiener',
    created: '04/16/2021',
    sla: '1d 3h',
  ),
];
