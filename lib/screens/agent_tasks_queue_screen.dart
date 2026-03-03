import 'package:flutter/material.dart';
import 'agent_detail_host_screen.dart';
import 'widgets/task_widgets.dart';

class AgentTasksQueueScreen extends StatelessWidget {
  const AgentTasksQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AgentDetailHostScreen(initialTabIndex: 3);
  }
}

class AgentTasksContent extends StatefulWidget {
  const AgentTasksContent({super.key});

  @override
  State<AgentTasksContent> createState() => _AgentTasksContentState();
}

class _AgentTasksContentState extends State<AgentTasksContent> {
  int _subTabIndex = 0; // "Active" sub-tab

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final paddingHorizontal = isMobile ? 16.0 : 48.0;

        return Column(
          children: [
            _buildTabs(isMobile),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: paddingHorizontal,
                  vertical: 32,
                ),
                children: [
                  const TaskListItem(
                    title: 'Review Marketing Copy: 123 Main St',
                    subtitle: 'Due: Today, 5:00 PM',
                    status: 'In Progress',
                  ),
                  const TaskListItem(
                    title: 'Analyze Buyer Sentiment: The Oakwoods',
                    subtitle: 'Due: Tomorrow, 10:00 AM',
                    status: 'Pending Review',
                  ),
                  const TaskListItem(
                    title: 'Generate Weekly Digest',
                    subtitle: 'Due: Friday, 4:00 PM',
                    status: 'Waiting',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabs(bool isMobile) {
    final tabs = ['Active', 'Completed', 'Disputed', 'Archived'];
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
                  onTap: () => setState(() => _subTabIndex = e.key),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 32,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: e.key == _subTabIndex
                          ? Colors.white.withValues(alpha: 0.02)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: e.key == _subTabIndex
                              ? const Color(0xFFCE9799)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: e.key == _subTabIndex
                            ? Colors.white
                            : const Color(0xFF9EA3AE),
                        fontSize: 14,
                        fontWeight: e.key == _subTabIndex
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
}
