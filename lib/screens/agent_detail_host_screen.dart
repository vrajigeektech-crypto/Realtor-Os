import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import '../utils/app_styles.dart';
import '../widgets/agent_detail_header.dart';
import 'agent_detail_profile_screen.dart';
import 'agent_spend_summary_compact_screen.dart';
import 'agent_tasks_queue_screen.dart';
import 'integrations_screen.dart';
import 'agent_security_screen.dart';

class AgentDetailHostScreen extends StatefulWidget {
  final int initialTabIndex;
  const AgentDetailHostScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AgentDetailHostScreen> createState() => _AgentDetailHostScreenState();
}

class _AgentDetailHostScreenState extends State<AgentDetailHostScreen> {
  late int _activeTabIndex;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
  }

  void _onTabTap(int index) {
    if (index == _activeTabIndex) return;
    setState(() {
      _activeTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Agent Detail - Profile',
      'Agent Detail - Spend',
      'Agent Detail - Usage',
      'Agent Detail - Tasks & Queue',
      'Agent Detail - Integrations',
      'Agent Detail - Assets',
      'Agent Detail - Onboarding',
      'Agent Detail - Security',
    ];

    return MainLayout(
      title: titles[_activeTabIndex],
      activeIndex: 8,
      child: Container(
        decoration: AppStyles.fidelityBackgroundDecoration(),
        child: Column(
          children: [
            AgentDetailHeader(
              activeIndex: _activeTabIndex,
              onTabTap: _onTabTap,
              title: titles[_activeTabIndex],
            ),
            Expanded(child: _getContent(_activeTabIndex)),
          ],
        ),
      ),
    );
  }

  Widget _getContent(int index) {
    switch (index) {
      case 0:
        return const AgentProfileContent();
      case 1:
        return const AgentSpendContent();
      case 3:
        return const AgentTasksContent();
      case 4:
        return const AgentIntegrationsContent();
      case 7:
        return const AgentSecurityContent();
      default:
        return Center(
          child: Text(
            'Tab $index Content coming soon',
            style: const TextStyle(color: Colors.white54),
          ),
        );
    }
  }
}    
