import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import '../utils/app_styles.dart';

class AutomationQueueScreen extends StatelessWidget {
  const AutomationQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Automation Queue',
      activeIndex: 4,
      child: const _AutomationQueueLayout(),
    );
  }
}

class _AutomationQueueLayout extends StatefulWidget {
  const _AutomationQueueLayout();

  @override
  State<_AutomationQueueLayout> createState() => _AutomationQueueLayoutState();
}

class _AutomationQueueLayoutState extends State<_AutomationQueueLayout> {
  int _tabIndex = 0; // "Running" sub-tab

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.fidelityBackgroundDecoration(),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Automation Queue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Monitor, pause, or resume automated workflows currently active in the system.',
            style: TextStyle(color: AppStyles.mutedText, fontSize: 16),
          ),
          const SizedBox(height: 32),
          _buildTabs(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Running', 'Scheduled', 'Paused', 'Review Required', 'History'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs
              .asMap()
              .entries
              .map(
                (e) => InkWell(
                  onTap: () => setState(() => _tabIndex = e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: e.key == _tabIndex
                          ? Colors.white.withValues(alpha: 0.02)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: e.key == _tabIndex
                              ? AppStyles.accentRose
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: e.key == _tabIndex
                            ? Colors.white
                            : AppStyles.mutedText,
                        fontSize: 14,
                        fontWeight: e.key == _tabIndex
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Currently Running (3 workflows)',
              style: TextStyle(
                color: AppStyles.copperBrush,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                _buildFilterButton('Sort by: Oldest First'),
                const SizedBox(width: 12),
                _buildFilterButton('Filter: All Agents'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildWorkflowCard(
          'Automated Lead Nurturing Sequence',
          'Agent: Communications Bot',
          'Running for 2h 15m. 4/12 leads processed.',
          0.33,
          'Active',
        ),
        const SizedBox(height: 16),
        _buildWorkflowCard(
          'Daily MLS Data Sync',
          'Agent: Data Harvester',
          'Running for 14m. Fetching new listings...',
          0.85,
          'Active',
        ),
        const SizedBox(height: 16),
        _buildWorkflowCard(
          'Review Requested Documents',
          'Agent: Compliance Assistant',
          'Running for 3h. Analyzing contract anomalies.',
          0.60,
          'Review Needed',
          statusColor: const Color(0xFFC05A5A),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(text, style: const TextStyle(color: AppStyles.mutedText, fontSize: 13)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down, color: AppStyles.mutedText, size: 16),
        ],
      ),
    );
  }

  Widget _buildWorkflowCard(
      String title, String agent, String desc, double progress, String status,
      {Color? statusColor}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.premiumCardDecoration(
        color: Colors.black.withValues(alpha: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (statusColor ?? AppStyles.statusGreen).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: (statusColor ?? AppStyles.statusGreen)
                          .withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor ?? AppStyles.statusGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            agent,
            style: const TextStyle(color: AppStyles.copperBrush, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(color: AppStyles.mutedText, fontSize: 14)),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: statusColor ?? AppStyles.accentRose,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Pause',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: AppStyles.subtleButtonDecoration(),
                child: TextButton(
                  onPressed: () {},
                  style:
                      TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20)),
                  child: const Text(
                    'View Details',
                    style: TextStyle(color: Colors.white, fontSize: 13),
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
