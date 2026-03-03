import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import '../utils/app_styles.dart';
import '../widgets/task_widgets.dart';

/// Realtor OS – Task Queue Screen
/// Refactored to use MainLayout and Professional Widgets.
class TaskQueueScreen extends StatelessWidget {
  const TaskQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Task Queue',
      activeIndex: 8, // Task
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return _buildMainArea(isMobile);
        },
      ),
    );
  }

  // MAIN AREA
  Widget _buildMainArea(bool isMobile) {
    final tasks = _mockTasks;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent, // MainLayout bg
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          _buildSearchRow(isMobile),
          const SizedBox(height: 12),
          const Divider(height: 0, color: AppStyles.borderSoft),
          if (!isMobile) _buildHeaderRow(),
          if (!isMobile) const Divider(height: 0, color: AppStyles.borderSoft),
          Expanded(
            child: ListView.separated(
              itemCount: tasks.length,
              padding: isMobile ? const EdgeInsets.all(12) : EdgeInsets.zero,
              separatorBuilder: (_, __) =>
                  const Divider(height: 0, color: AppStyles.borderSoft),
              itemBuilder: (context, index) {
                if (isMobile) {
                  return TaskMobileCard(row: tasks[index]);
                }
                return TaskTableRow(row: tasks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppStyles.panelColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppStyles.borderSoft),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, size: 18, color: AppStyles.mutedText),
                  SizedBox(width: 8),
                  Text(
                    'Search tasks...',
                    style: TextStyle(color: AppStyles.mutedText, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    Text header(String s) => Text(
      s,
      style: const TextStyle(
        color: AppStyles.mutedText,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );

    return Container(
      color: Colors.white.withValues(alpha: 0.02),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 90, child: header('Task ID')),
          const SizedBox(width: 12),
          SizedBox(width: 180, child: header('Agent')),
          const SizedBox(width: 12),
          SizedBox(width: 150, child: header('Task Type')),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Row(
              children: [
                header('Priority'),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppStyles.mutedText,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: header('Post Content')),
          const SizedBox(width: 12),
          SizedBox(width: 120, child: header('Status')),
          const SizedBox(width: 12),
          SizedBox(width: 120, child: header('SLA Countdown')),
          const SizedBox(width: 12),
          SizedBox(width: 160, child: header('Actions')),
        ],
      ),
    );
  }

  // MOCK DATA
  static List<TaskRowData> get _mockTasks => const [
    TaskRowData(
      agentInitials: 'FM',
      agentName: 'Frank Miller',
      agentOrg: 'Miller Realty',
      agentMeta: '57 Tasks · Joined Sep 2023',
      taskType: 'TikTok Promo',
      taskTag: 'Expedited Boost',
      priority: 'Standard',
      postTitle: 'Marketing Reel Promo Video',
      postSubtitle: 'Refined & Cinematic',
      status: 'Briefing',
      slaShort: '59m',
      slaFull: '59m 5m',
    ),
    TaskRowData(
      agentInitials: 'SD',
      agentName: 'Sarah Davis',
      agentOrg: 'Lux Property Group',
      agentMeta: '42 Tasks · Joined 2023',
      taskType: 'Facebook Lead Ads',
      taskTag: null,
      priority: 'High',
      postTitle: 'High Net Worth Buyers · Luxury Homes Interior',
      postSubtitle: 'Instagram Reels',
      status: 'Briefing',
      slaShort: '7h 12m',
      slaFull: '7h 12m',
    ),
    TaskRowData(
      agentInitials: 'MJ',
      agentName: 'Mark Johnson',
      agentOrg: 'PrimeProperty Group',
      agentMeta: 'History: Last 7m ago',
      taskType: 'Sales Call Campaign',
      taskTag: 'Automation CRM Connect',
      priority: 'Standard',
      postTitle: 'Cold Calls',
      postSubtitle: 'CRM APIs · 4671****C767****',
      status: 'In Progress',
      slaShort: '1d 8h',
      slaFull: '1d 8h',
    ),
    TaskRowData(
      agentInitials: 'SD',
      agentName: 'Sarah Davis',
      agentOrg: 'Lux Property Group',
      agentMeta: '42 Tasks · Joined 2023',
      taskType: 'Facebook Lead Ads',
      taskTag: null,
      priority: 'High',
      postTitle: 'Targeting',
      postSubtitle: 'CRM APIs · 4971***567',
      status: 'In Progress',
      slaShort: '1d 8h',
      slaFull: '1d 8h',
    ),
  ];
}
