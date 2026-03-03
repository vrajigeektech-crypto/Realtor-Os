import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RecommendedActionModel {
  final String id;
  final String title;
  final String description;
  final String? ctaLabel;
  RecommendedActionModel({
    required this.id,
    required this.title,
    required this.description,
    this.ctaLabel,
  });
}

class TeamLeadActionsController {
  final isLoading = _RxBool(false);
  final recommendedActions = <RecommendedActionModel>[];
}

class BrokerActionsController {
  final isLoading = _RxBool(false);
  final recommendedActions = <RecommendedActionModel>[];
}

class _RxBool {
  bool _value;
  _RxBool(this._value);
  bool get value => _value;
  set value(bool v) => _value = v;
}

class Get {
  static T put<T>(T Function() factory) => factory();
}

Widget Obx(Widget Function() builder) => builder();

class BrokerDashboardWidget extends StatefulWidget {
  const BrokerDashboardWidget({super.key});

  @override
  State<BrokerDashboardWidget> createState() => _BrokerDashboardWidgetState();
}

class _BrokerDashboardWidgetState extends State<BrokerDashboardWidget> {
  final TeamLeadActionsController _teamLeadActionsController = Get.put(() => TeamLeadActionsController());
  final BrokerActionsController _brokerActionsController = Get.put(() => BrokerActionsController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF4A3436), width: 1),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFCE9799).withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Metallic Bar
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
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
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(children: [_buildTopStatsBar()]),
                  const SizedBox(height: 12),
                  Divider(
                    color: Color(0xFFCE9799).withOpacity(0.3),
                    thickness: 1,
                  ),
                  Obx(() {
                    if (_brokerActionsController.isLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFFCE9799),
                          ),
                        ),
                      );
                    }
                    if (_brokerActionsController
                        .recommendedActions
                        .isNotEmpty) {
                      return Column(
                        children: [
                          _buildDynamicRecommendedActions(
                            _brokerActionsController.recommendedActions,
                            title: 'BROKER RECOMMENDED ACTIONS',
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  Obx(() {
                    if (_teamLeadActionsController.isLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFFCE9799),
                          ),
                        ),
                      );
                    }
                    if (_teamLeadActionsController.recommendedActions.isEmpty) {
                      return _buildStaticRecommendedActions();
                    }
                    return _buildDynamicRecommendedActions(
                      _teamLeadActionsController.recommendedActions,
                    );
                  }),

                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Top Performers
                      Expanded(flex: 3, child: _buildTopPerformersList()),
                      const SizedBox(width: 24),
                      // Middle: Agent Performance
                      Expanded(flex: 6, child: _buildAgentPerformanceGrid()),
                      const SizedBox(width: 24),
                      // Right: Team Activity & Detail
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildTeamActivityFeed(),
                            const SizedBox(height: 24),
                            _buildVisualROI(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Bottom Section: Heatmap + Grow Team
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildTeamHeatmap()),
                      SizedBox(width: 24),
                      Expanded(flex: 6, child: _buildBottomBanner()),
                      // Spacer to balance layout if needed, or another metric
                      SizedBox(width: 24),
                      Expanded(flex: 3, child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
            // Bottom Metallic Bar
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
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
    );
  }

  Widget _buildTopStatsBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('Brokerage Brand Score: A+', isBold: true),
        _buildStatItem('Total Impressions: 2.5M'),
        _buildStatItem('Total Reach Rate: 2.0M'),
        _buildStatItem('Total Communities: 990'),
        _buildStatItem('Total Vetted Leads: -12'),
        _buildStatItem('OST Synergy Bonus: -8,750 OST'),
        Row(
          children: [
            Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 20),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54),
              ),
              child: Icon(
                Icons.currency_bitcoin,
                color: Colors.white54,
                size: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDynamicRecommendedActions(
    List<RecommendedActionModel> actions, {
    String title = 'RECOMMENDED ACTIONS FOR YOU THIS WEEK',
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A3436), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of the section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: const Color(0xFF4A3436)),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: actions.map((action) {
                  return Container(
                    width: 350,
                    margin: const EdgeInsets.only(right: 20),
                    child: _buildActionCard(
                      title: action.title,
                      description: action.description,
                      buttonLabel: action.ctaLabel ?? '',
                      onTap: () {},
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticRecommendedActions() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A3436), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of the section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: const Color(0xFF4A3436)),
              ),
            ),
            child: const Text(
              'RECOMMENDED ACTIONS FOR YOU THIS WEEK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'Assign Database Calling\nto Inactive Agents',
                    description:
                        'Ensure all leads are being contacted\nby less active team members.',
                    buttonLabel: 'ASSIGN TASKS',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildActionCard(
                    title: 'Push BPA Automation to\nUnder-Qualified Buyers',
                    description:
                        'Increase conversion by automating nurture\nsequences for unready prospects.',
                    buttonLabel: 'PUSH AUTOMATION',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildActionCard(
                    title: 'Invite New Agents to\nUnlock Team Bonus',
                    description:
                        'Reach your team bonus threshold by\nadding new, motivated agents.',
                    buttonLabel: 'INVITE NEW AGENTS',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A3436), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCE9799).withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: const Color(0xFFCE9799).withOpacity(0.4),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  backgroundColor: const Color(0xFF1F1F1F),
                ),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(
                    color: Color(0xFFCE9799),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String text, {bool isBold = false}) {
    var parts = text.split(':');
    String label = parts[0];
    String value = parts.length > 1 ? parts[1] : '';

    return Row(
      children: [
        Text(
          parts.length > 1 ? "$label: " : label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
        if (value.isNotEmpty)
          Text(
            value,
            style: TextStyle(
              color: isBold ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
      ],
    );
  }

  Widget _buildTopPerformersList() {
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white12, width: 1)),
      ),
      padding: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Performers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Leaderboard',
                style: TextStyle(color: Colors.white24, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPerformerItem(
            'Arye S. Siuile Bice',
            'Product 200/2000 Deals',
            1,
          ),
          const Divider(color: Colors.white10),
          _buildPerformerItem('Rast S. Easlee Biles', 'Pitch: 200 Deals', 2),
          const Divider(color: Colors.white10),
          _buildPerformerItem('Comesstions', 'Stirring Rock', 3),
          const Divider(color: Colors.white10),
          _buildPerformerItem('Callist & Pian Wetes', 'Sales Track', 4),
          const Divider(color: Colors.white10),
          _buildPerformerItem('Sean & Phetins', '90/Streak', 5),
          const Divider(color: Colors.white10),
          _buildPerformerItem('KIP Zamaoit Brock', '90/Streak', 6),
        ],
      ),
    );
  }

  Widget _buildPerformerItem(String name, String subtitle, int rank) {
    Widget rankBadge;
    if (rank == 1) {
      rankBadge = Icon(
        Icons.emoji_events,
        color: Color(0xFFD4AF37),
        size: 18,
      ); // Gold
    } else if (rank == 2) {
      rankBadge = Icon(
        Icons.emoji_events,
        color: Color(0xFFC0C0C0),
        size: 18,
      ); // Silver
    } else if (rank == 3) {
      rankBadge = Icon(
        Icons.emoji_events,
        color: Color(0xFFCD7F32),
        size: 18,
      ); // Bronze
    } else {
      rankBadge = SizedBox(width: 18);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[800],
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$name'),
            radius: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
          rankBadge,
        ],
      ),
    );
  }

  Widget _buildAgentPerformanceGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Agent Performance",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _buildAgentCard(
              "Roolia Purnad",
              "85K",
              "Impressions (79)",
              "Rootles (79)",
              "-100 OST",
            ),
            _buildAgentCard(
              "Pocola Purnad",
              "70K",
              "Impressions (79)",
              "Reodlts (70)",
              "-100 OST",
            ),
            _buildAgentCard(
              "Piocka Purnad",
              "70K",
              "Impressions (78)",
              "Booklets (70)",
              "-410 OST",
            ),
            _buildAgentCard(
              "Aalyah Rantasi",
              "22",
              "Cities Completed (10)",
              "Granted (70)",
              "-130 OST",
            ),
            _buildAgentCard(
              "Clevr DMS",
              "70K",
              "Clever DMS",
              "Deducts (70)",
              "-100 OST",
            ),
            _buildAgentCard(
              "CCRM FENE",
              "56K",
              "CCRM FEKE",
              "Deeds (70)",
              "-180 OST",
            ),
            _buildAgentCard(
              "AGENT RAMAISS",
              "85K",
              "AGENT BRAINS",
              "Rowelod (70)",
              "-100 OST",
            ),
            _buildAgentCard(
              "CHOIK STRIGS",
              "26K",
              "CHOIK STRINGS",
              "Oedas (70)",
              "-100 OST",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgentCard(
    String name,
    String value,
    String topLabel,
    String subName,
    String ostValue,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                topLabel,
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              Icon(Icons.more_horiz, color: Colors.white24, size: 14),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[800],
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=$name',
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    subName,
                    style: TextStyle(color: Colors.white54, fontSize: 9),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  height: 30,
                  margin: EdgeInsets.only(left: 8),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 10,
                      minY: 0,
                      maxY: 6,
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            FlSpot(0, 1),
                            FlSpot(2, 3),
                            FlSpot(4, 2),
                            FlSpot(6, 4),
                            FlSpot(8, 3),
                            FlSpot(10, 5),
                          ],
                          isCurved: true,
                          color: Color(0xFFCE9799),
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "XP Used: 19 (0.2%)",
                style: TextStyle(color: Colors.white38, fontSize: 9),
              ),
              Text(
                ostValue,
                style: TextStyle(color: Colors.white38, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamActivityFeed() {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.white12, width: 1)),
      ),
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Team Activity Feed",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _buildFeedItem(
            Icons.camera_alt_outlined,
            "Jade R. posted on IG Carousel",
            "5m ago",
          ),
          SizedBox(height: 16),
          _buildFeedItem(
            Icons.phone,
            "Marco S. completed 8 calls calls",
            "10m ago",
          ),
          SizedBox(height: 16),
          _buildFeedItem(Icons.phone, "Marco S. completed 9 calls", "15m ago"),
          SizedBox(height: 16),
          _buildFeedItem(
            Icons.play_circle_outline,
            "Aaliyah K. launched webinar",
            "22m ago",
          ),
          SizedBox(height: 16),
          _buildFeedItem(
            Icons.chat_bubble_outline,
            "Drew F. generated 4 buyer convos",
            "30m ago",
          ),
        ],
      ),
    );
  }

  Widget _buildFeedItem(IconData icon, String text, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white38, size: 18),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: TextStyle(color: Colors.white, fontSize: 12)),
              Text(time, style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamHeatmap() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Team Heat Map",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hot (Bidding)",
                style: TextStyle(color: Color(0xFFCE9799), fontSize: 10),
              ),
              Text(
                "Stable",
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
          SizedBox(height: 8),
          _buildHeatmapBar(
            label: "Entering",
            value: 0.8,
            color: Color(0xFFD3455B),
            labelColor: Colors.white38,
          ),
          SizedBox(height: 6),
          _buildHeatmapBar(
            label: "Coasting",
            value: 0.6,
            color: Color(0xFF4A90E2),
            labelColor: Colors.white38,
          ),
          SizedBox(height: 6),
          _buildHeatmapBar(
            label: "Inactive",
            value: 0.2,
            color: Color(0xFFF5A623),
            labelColor: Colors.white38,
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapBar({
    required String label,
    required double value,
    required Color color,
    required Color labelColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Text(label, style: TextStyle(color: labelColor, fontSize: 9)),
      ],
    );
  }

  Widget _buildVisualROI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Brokerage ROI",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        _buildROIRow("Least Cost Reduction", "Broad Exposure LIR", "-12%"),
        Divider(color: Colors.white12),
        _buildROIRow("System Output Per Agent", "", "+35%"),
      ],
    );
  }

  Widget _buildROIRow(String title, String sub, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/150?u=$title",
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  if (sub.isNotEmpty)
                    Text(
                      sub,
                      style: TextStyle(color: Colors.white38, fontSize: 9),
                    ),
                ],
              ),
            ],
          ),
          Text(
            val,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBanner() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFFCE9799).withOpacity(0.05),
            Color(0xFF1A1A1A),
          ],
          begin: Alignment(0, -1),
          end: Alignment(0, 1),
        ),
        borderRadius: BorderRadius.circular(0), // Looks integrated
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "GROW YOUR TEAM",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Connect New Agents & Scale Your Organization",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFCE9799).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFCE9799),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ), // Sharp futuristic cut
              ),
              child: Text(
                "INVITE NEW AGENTS",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
