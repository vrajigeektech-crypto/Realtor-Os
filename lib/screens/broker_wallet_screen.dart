import 'package:flutter/material.dart';
import '../../layout/main_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'controller/auth_controller.dart';

class BrokerWalletScreen extends StatefulWidget {
  const BrokerWalletScreen({super.key});

  @override
  State<BrokerWalletScreen> createState() => _BrokerWalletScreenState();
}

class _BrokerWalletScreenState extends State<BrokerWalletScreen> {
  final Color accentColor = const Color(0xFFCE9799);
  final Color borderColor = const Color(0xFF4A3436);
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    // final double screenWidth = MediaQuery.of(context).size.width;

    return MainLayout(
      isBroker: true,
      title: 'Wallet',
      activeIndex: 5,
      headerExtras: [
        if (!isMobile) // Desktop header extras
          Row(
            children: [
              Obx(
                () => Text(
                  authController.user.value?.name ?? 'Anderson Brokerage',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(width: 40),
              Text(
                '17,450,200 ',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'OST',
                style: GoogleFonts.inter(
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 20),
              Icon(Icons.notifications_none, color: accentColor, size: 24),
            ],
          ),
      ],
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            border: Border.all(color: const Color(0xFF4A3436), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCE9799).withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Metallic Bar
              Container(
                height: isMobile ? 8 : 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMobile ? 16 : 20),
                    topRight: Radius.circular(isMobile ? 16 : 20),
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2A2A2A),
                      Color(0xFF5A4A4C),
                      Color(0xFF2A2A2A),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: borderColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mobile header with balance
                    if (isMobile) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(
                            () => Text(
                              authController.user.value?.name ?? 'Anderson Brokerage',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '17.4M ',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'OST',
                                style: GoogleFonts.inter(
                                  color: accentColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildSectionTitle(
                      'Broker Token Wallet Overview',
                      isMobile: isMobile,
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    _buildBrokerTokenWalletOverview(isMobile: isMobile),
                    SizedBox(height: isMobile ? 24 : 40),

                    _buildSectionTitle(
                      'Broker Spend Ledger',
                      isMobile: isMobile,
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    _buildBrokerSpendLedger(isMobile: isMobile),
                    SizedBox(height: isMobile ? 24 : 40),

                    _buildSectionTitle(
                      'Token Velocity & Health',
                      isMobile: isMobile,
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    _buildTokenVelocityHealth(isMobile: isMobile),
                    SizedBox(height: isMobile ? 24 : 40),

                    _buildSectionTitle(
                      'Agent Allowances & Controls',
                      isMobile: isMobile,
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    _buildAgentAllowancesControls(isMobile: isMobile),
                    SizedBox(height: isMobile ? 24 : 40),

                    // Responsive layout for last two sections
                    if (isMobile)
                      Column(
                        children: [
                          _buildSectionTitle(
                            'Performance Incentives',
                            isMobile: isMobile,
                          ),
                          const SizedBox(height: 12),
                          _buildPerformanceIncentives(isMobile: isMobile),
                          const SizedBox(height: 24),
                          _buildSectionTitle(
                            'Subscriptions & Auto-Funding',
                            isMobile: isMobile,
                          ),
                          const SizedBox(height: 12),
                          _buildSubscriptionsAutoFunding(isMobile: isMobile),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(
                                  'Performance Incentives',
                                  isMobile: isMobile,
                                ),
                                const SizedBox(height: 16),
                                _buildPerformanceIncentives(isMobile: isMobile),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(
                                  'Subscriptions & Auto-Funding',
                                  isMobile: isMobile,
                                ),
                                const SizedBox(height: 16),
                                _buildSubscriptionsAutoFunding(
                                  isMobile: isMobile,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: isMobile ? 40 : 60),
                  ],
                ),
              ),
              // Bottom Metallic Bar
              Container(
                height: isMobile ? 8 : 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(isMobile ? 16 : 20),
                    bottomRight: Radius.circular(isMobile ? 16 : 20),
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2A2A2A),
                      Color(0xFF5A4A4C),
                      Color(0xFF2A2A2A),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isMobile = false}) {
    return Text(
      title,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: isMobile ? 14 : 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildBrokerTokenWalletOverview({bool isMobile = false}) {
    return Container(
      width: double.infinity,
      decoration: _metallicDecoration(),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      isMobile ? '17.4M' : '17,450,200',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: isMobile ? 36 : 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: isMobile ? 1 : 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'OST',
                      style: GoogleFonts.inter(
                        color: accentColor,
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 100,
                  ),
                  child: Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
          if (isMobile)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  _buildOverviewSubStat(
                    'Available Tokens',
                    '8,250,000',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 16),
                  _buildOverviewSubStat(
                    'Committed Tokens',
                    '6,900,000',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 16),
                  _buildOverviewSubStat(
                    'Auto-Allocated Tokens',
                    '2,300,200',
                    isMobile: isMobile,
                  ),
                ],
              ),
            )
          else
            IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOverviewSubStat(
                      'Available Tokens',
                      '8,250,000',
                      isMobile: isMobile,
                    ),
                    _buildDivider(),
                    _buildOverviewSubStat(
                      'Committed Tokens',
                      '6,900,000',
                      isMobile: isMobile,
                    ),
                    _buildDivider(),
                    _buildOverviewSubStat(
                      'Auto-Allocated Tokens',
                      '2,300,200',
                      isMobile: isMobile,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewSubStat(
    String label,
    String value, {
    bool isMobile = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'OST',
              style: GoogleFonts.inter(
                color: Colors.white38,
                fontSize: isMobile ? 10 : 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, color: Colors.white.withOpacity(0.05));
  }

  Widget _buildBrokerSpendLedger({bool isMobile = false}) {
    return Container(
      decoration: _metallicDecoration(),
      child: Column(
        children: [
          if (!isMobile) _buildLedgerHeader(isMobile: isMobile),
          _buildLedgerRow(
            'Jason Reed',
            '475,000',
            '5 Active Deals',
            '4 Closings',
            statusColor: Colors.green,
            imageUrl: 'https://i.pravatar.cc/150?u=jason',
            progress: 0.8,
            isMobile: isMobile,
          ),
          _buildLedgerRow(
            'Laura Chen',
            '360,000',
            '4 Active Deals',
            '2 Closings, 1 Pending',
            statusColor: Colors.yellow,
            imageUrl: 'https://i.pravatar.cc/150?u=laura',
            progress: 0.6,
            isMobile: isMobile,
          ),
          _buildLedgerRow(
            'Mark Stevens',
            '295,000',
            '3 Active Deals',
            '3 Closings',
            statusColor: Colors.green,
            imageUrl: 'https://i.pravatar.cc/150?u=mark',
            progress: 0.5,
            isMobile: isMobile,
          ),
          _buildLedgerRow(
            'Kelly Tran',
            '210,000',
            '2 Active Deals',
            '—',
            statusColor: Colors.white24,
            imageUrl: 'https://i.pravatar.cc/150?u=kelly',
            progress: 0.4,
            isMobile: isMobile,
            isLast: true,
          ),
          if (!isMobile) _buildLedgerFooter(),
        ],
      ),
    );
  }

  Widget _buildLedgerHeader({bool isMobile = false}) {
    if (isMobile) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _headerText('Agent')),
          Expanded(flex: 3, child: _headerText('Tokens Spent (Last 30 Days)')),
          Expanded(flex: 2, child: _headerText('Active Commitments')),
          Expanded(flex: 2, child: _headerText('Outcomes')),
        ],
      ),
    );
  }

  Widget _headerText(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildLedgerRow(
    String name,
    String spent,
    String commitments,
    String outcomes, {
    required Color statusColor,
    required String imageUrl,
    required double progress,
    bool isMobile = false,
    bool isLast = false,
  }) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        spent + ' OST',
                        style: GoogleFonts.inter(
                          color: accentColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (outcomes != '—')
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Commitments: $commitments',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            if (outcomes != '—') ...[
              const SizedBox(height: 8),
              Text(
                'Outcomes: $outcomes',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
            ],
            const SizedBox(height: 12),
            _buildSegmentedProgressBar(progress, height: 6),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text(
                  spent,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'OST',
                  style: GoogleFonts.inter(color: accentColor, fontSize: 10),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildSegmentedProgressBar(progress)),
                const SizedBox(width: 20),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              commitments,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (outcomes != '—')
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 10),
                Text(
                  outcomes,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            'Expand',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenVelocityHealth({bool isMobile = false}) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _metallicDecoration(),
        child: Column(
          children: [
            _buildHealthMetric(
              'Monthly Burn Rate',
              'Stable',
              0.4,
              Colors.brown,
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),
            _buildHealthMetric(
              '1,250,000 OST',
              'Optimal',
              0.7,
              Colors.green,
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),
            _buildHealthMetric(
              '86,700 OST',
              'Optimal',
              0.6,
              Colors.blueGrey,
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),
            _buildHealthMetric(
              '65% Automated',
              'Efficient',
              0.8,
              Colors.green,
              isMobile: isMobile,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: _metallicDecoration(),
      child: Row(
        children: [
          Expanded(
            child: _buildHealthMetric(
              'Monthly Burn Rate',
              'Stable',
              0.4,
              Colors.brown,
              isMobile: isMobile,
            ),
          ),
          _buildVerticalSeparator(),
          Expanded(
            child: _buildHealthMetric(
              '1,250,000 OST',
              'Optimal',
              0.7,
              Colors.green,
              isMobile: isMobile,
            ),
          ),
          _buildVerticalSeparator(),
          Expanded(
            child: _buildHealthMetric(
              '86,700 OST',
              'Optimal',
              0.6,
              Colors.blueGrey,
              isMobile: isMobile,
            ),
          ),
          _buildVerticalSeparator(),
          Expanded(
            child: _buildHealthMetric(
              '65% Automated',
              'Efficient',
              0.8,
              Colors.green,
              isMobile: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalSeparator() {
    return Container(
      height: 60,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildHealthMetric(
    String title,
    String label,
    double progress,
    Color color, {
    bool isMobile = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        _buildSegmentedProgressBar(
          progress,
          height: isMobile ? 8 : 10,
          color: color,
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 4 : 4,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: color.withOpacity(0.9),
              fontSize: isMobile ? 10 : 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgentAllowancesControls({bool isMobile = false}) {
    return Container(
      decoration: _metallicDecoration(),
      child: Column(
        children: [
          _buildAllowanceControlItem(
            'Max Cap: 500,000 OST',
            null,
            isMobile: isMobile,
          ),
          _buildAllowanceControlItem(
            'Marketing Limit: 150,000 OST',
            null,
            isMobile: isMobile,
          ),
          _buildAllowanceControlItem(
            'Auto-Pause at 80% Cap',
            true,
            isMobile: isMobile,
          ),
          _buildAllowanceControlItem(
            'Approvals Over 100,000 OST',
            true,
            isMobile: isMobile,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAllowanceControlItem(
    String title,
    bool? hasArrow, {
    bool isMobile = false,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 14 : 16,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: isMobile ? 13 : 14,
              ),
            ),
          ),
          if (hasArrow == true)
            Icon(
              Icons.chevron_right,
              color: Colors.white24,
              size: isMobile ? 18 : 20,
            ),
        ],
      ),
    );
  }

  Widget _buildPerformanceIncentives({bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: _metallicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIncentiveItem(
            'Close 5 Deals = +50,000 OST',
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          _buildIncentiveItem(
            'Top Producer Bonus = 200,000 OST',
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildIncentiveItem(String text, {bool isMobile = false}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: isMobile ? 12 : 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionsAutoFunding({bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: _metallicDecoration(),
      child: Column(
        children: [
          _buildSubscriptionItem(
            'MLS Subscription',
            'Next Charge: May 1, 2022',
            'Auto Top-Up: Enabled',
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 24),
          _buildSubscriptionItem(
            'Agent CRM Platform',
            'Next Charge: April 15, 2022',
            'Auto Top-Up: Active',
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionItem(
    String title,
    String nextCharge,
    String status, {
    bool isMobile = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.account_balance_wallet_outlined,
          color: accentColor,
          size: isMobile ? 18 : 20,
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: isMobile ? 10 : 11,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              nextCharge,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: isMobile ? 10 : 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              status.split(':').last.trim(),
              style: GoogleFonts.inter(
                color: Colors.white38,
                fontSize: isMobile ? 10 : 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSegmentedProgressBar(
    double progress, {
    double height = 4,
    Color? color,
    int segments = 8,
  }) {
    return Row(
      children: List.generate(segments, (index) {
        final double segmentThreshold = (index + 1) / segments;
        final bool isActive = progress >= segmentThreshold;
        return Expanded(
          child: Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: isActive
                  ? (color ?? accentColor).withOpacity(0.8)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(1),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: (color ?? accentColor).withOpacity(0.2),
                        blurRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  BoxDecoration _metallicDecoration() {
    return BoxDecoration(
      color: Colors.black.withOpacity(0.4),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withOpacity(0.05), Colors.transparent],
      ),
    );
  }
}
