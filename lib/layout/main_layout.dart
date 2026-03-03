import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/google_integrations_screen.dart';
import '../new_flow/features/social_integrations/screens/social_media_integrations_screen.dart';
import '../new_flow/features/payments_infra_integrations/screens/payments_infrastructure_integrations_screen.dart';
import '../new_flow/features/integrations/screens/master_page.dart';
import '../new_flow/features/integrations/routes/google_integration_routes.dart';
import '../new_flow/features/integrations/widgets/integrations_drawer_button.dart';
import '../new_flow/Core Money Engine/speed_to_lead_activation_screen.dart';
import '../new_flow/Core Money Engine/speed_to_lead_state_model.dart';
import '../new_flow/Core Money Engine/speed_to_lead_activation_controller.dart';
import '../new_flow/Core Money Engine/speed_to_lead_metric_model.dart';
import '../new_flow/Core Money Engine/lead_arrival_model.dart';
import '../new_flow/Core Money Engine/speed_to_lead_metric_key.dart';
import '../screens/wallet_screen.dart';
import '../services/balance_service.dart';
// TODO: Re-enable when screens are implemented
// import '../screens/calendar/calendar_screen.dart';
// import '../screens/automation/automation_screen.dart';
// import '../screens/agreement/agreement_screen.dart';
// import '../screens/notification/notification_center_screen.dart';
// import '../screens/properties/properties_screen.dart';
// import '../screens/wallet/wallet_screen.dart';
// import '../screens/task/task_detail_screen.dart';
// import '../screens/call/call_report_screen.dart';
// import '../screens/broker/broker_dashboard_screen.dart';
// import '../screens/broker/create_task_pack_screen.dart';
// import '../screens/broker/broker_intelligence_screen.dart';
// import '../screens/broker/team_performance_screen.dart';
// import '../screens/broker/broker_lead_overview_screen.dart';
// import '../screens/broker/broker_wallet_screen.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final int activeIndex; // 0: Dashboard, 1: Properties, etc.
  final bool isBroker;
  final List<Widget>? headerExtras;

  const MainLayout({
    super.key,
    required this.child,
    this.title = 'Realtor OS',
    this.activeIndex = 0,
    this.isBroker = false,
    this.headerExtras,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSidebarOpen = true;
  final BalanceService _balanceService = BalanceService();

  @override
  void initState() {
    super.initState();
    _balanceService.initialize();
  }

  @override
  void dispose() {
    _balanceService.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-close on smaller screens (< 1000px)
    final width = MediaQuery.of(context).size.width;
    if (width < 1000) {
      setState(() {
        _isSidebarOpen = false;
      });
    } else {
      setState(() {
        _isSidebarOpen = true;
      });
    }
  }

  void _toggleSidebar() {
    final width = MediaQuery.of(context).size.width;
    if (width < 1000) {
      // On mobile, don't do anything since we removed the drawer
      return;
    } else {
      setState(() {
        _isSidebarOpen = !_isSidebarOpen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 1000;

    // Force sidebar state based on screen size
    if (isMobile && _isSidebarOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isSidebarOpen = false;
          });
        }
      });
    } else if (!isMobile && !_isSidebarOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isSidebarOpen = true;
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      // Show drawer only on mobile
      drawer: isMobile ? _buildMobileDrawer(context) : null,

      body: Column(
        children: [
          _buildTopNavigationBar(context),
          Expanded(
            child: Row(
              children: [
                // Only show sidebar on desktop
                if (!isMobile)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isSidebarOpen ? 250 : 70,
                    curve: Curves.easeInOut,
                    child: _buildSidebar(context),
                  ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(color: Color(0xFF0A0A0A)),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigationBar(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromRGBO(206, 151, 153, 0.5),
          width: 2,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Section
              Flexible(
                child: Row(
                  children: [
                    Builder(
                      builder: (context) {
                        return IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Color(0xFFCE9799),
                            size: 28,
                          ),
                          onPressed: () {
                            final width = MediaQuery.of(context).size.width;
                            if (width < 1000) {
                              // On mobile, open the drawer
                              Scaffold.of(context).openDrawer();
                            } else {
                              _toggleSidebar();
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    if (!isMobile) ...[
                      const Icon(
                        Icons.home_work_outlined,
                        color: Color(0xFFCE9799),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Right Section
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.headerExtras != null) ...widget.headerExtras!,
                  if (widget.headerExtras != null) const SizedBox(width: 20),

                  // OST Balance - Only show outside wallet screen
                  if (!isMobile && widget.activeIndex != 2) ...[
                    StreamBuilder<double>(
                      stream: _balanceService.balanceStream,
                      initialData: _balanceService.currentBalance,
                      builder: (context, snapshot) {
                        final balance = snapshot.data ?? 0.0;
                        return Text(
                          'OST Balance: ${_balanceService.formatBalance(balance)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                  ],

                  // Globe Icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFCE9799),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.public,
                      color: Color(0xFFCE9799),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 20),

                  if (!isMobile) ...[
                    Container(width: 1, height: 24, color: Colors.white24),
                    const SizedBox(width: 20),
                  ],

                  // Calendar
                  GestureDetector(
                    onTap: () {
                      // TODO: Re-enable when CalendarScreen is implemented
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const CalendarScreen(),
                      //   ),
                      // );
                    },
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFFCE9799),
                      size: 22,
                    ),
                  ),

                  if (!isMobile) ...[
                    const SizedBox(width: 12),
                    const Text(
                      'VA Assignments (3)',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(width: 20),
                    Container(width: 1, height: 24, color: Colors.white24),
                    const SizedBox(width: 20),
                  ],

                  if (isMobile) const SizedBox(width: 20),

                  // Notifications (Sender?)
                  GestureDetector(
                    onTap: () {
                      // TODO: Re-enable when NotificationCenterScreen is implemented
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         const NotificationCenterScreen(),
                      //   ),
                      // );
                    },
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_none, // Updated to match view
                          color: Color(0xFFCE9799),
                          size: 22,
                        ),
                        /* Notification dot logic if needed */
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Integrations Drawer Button
                  IntegrationsDrawerButton(
                    userId: 'fc6183ec-f307-4a34-a101-e805b6975699', // Use current user ID
                    onIntegrationTap: (integrationKey) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped integration: $integrationKey')),
                      );
                    },
                  ),
                  const SizedBox(width: 12),

                  // Status / Profile Area
                  if (!isMobile)
                    Row(
                      children: [
                        const Text(
                          'VA Assignments: ',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const Text(
                          'Operational',
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green,
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF111111),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: Color(0xFFCE9799), width: 1),
          ),
        ),
        child: _buildDrawerContent(context, isDrawer: true),
      ),
    );
  }

  Widget _buildDrawerContent(BuildContext context, {bool isDrawer = false}) {
    // Show the regular sidebar
    return _buildSidebar(context, isDrawer: isDrawer);
  }

  Widget _buildSidebar(BuildContext context, {bool isDrawer = false}) {
    return Container(
      margin: isDrawer
          ? EdgeInsets.zero
          : const EdgeInsets.only(left: 10, bottom: 10, right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: isDrawer ? null : BorderRadius.circular(12),
        border: isDrawer
            ? const Border(
                right: BorderSide(color: Color(0xFFCE9799), width: 1),
              )
            : Border.all(
                color: const Color.fromRGBO(206, 151, 153, 0.5),
                width: 2,
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Sidebar Header with Menu Toggle
          if (!isDrawer)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 0,
              ), // Use center alignment for icon when collapsed
              child: Row(
                mainAxisAlignment: _isSidebarOpen
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  if (_isSidebarOpen)
                    const SizedBox(width: 24), // Left padding only when open
                  GestureDetector(
                    onTap: _toggleSidebar, // Toggle sidebar open/close
                    child: const Icon(
                      Icons.menu,
                      color: Color(0xFFCE9799), // Pink color as requested
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          if (!isDrawer) const SizedBox(height: 30), // Spacing after menu icon
          Expanded(
            child: ListView(
              children: [
                if (widget.isBroker) ...[
                  _buildSidebarItem(
                    context,
                    Icons.dashboard_outlined,
                    'Dashboard',
                    0,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    context,
                    Icons.add_task,
                    'Create Task Pack',
                    1,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    context,
                    Icons.rss_feed,
                    'Intelligence Feed',
                    2,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    context,
                    Icons.group,
                    'Team Performance',
                    3,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    context,
                    Icons.leaderboard,
                    'Lead Overview',
                    4,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(context, Icons.wallet, 'Broker Wallet', 5, isDrawer: isDrawer),
                ] else ...[
                  _buildSidebarItem(
                    context,
                    Icons.dashboard_outlined,
                    'Dashboard',
                    0,
                  ),
                  _buildSidebarItem(context, Icons.apartment, 'Properties', 1, isDrawer: isDrawer),
                  _buildSidebarItem(
                    context,
                    Icons.account_balance_wallet_outlined,
                    'Wallet',
                    2,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    context,
                    Icons.description_outlined,
                    'Agreements',
                    3,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(context, Icons.folder_open, 'Files', 4, isDrawer: isDrawer),
                  _buildSidebarItem(
                    context,
                    Icons.auto_fix_high,
                    'Automation',
                    5,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    context,
                    Icons.settings_outlined,
                    'Settings',
                    6,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    context,
                    Icons.admin_panel_settings_outlined,
                    'Admin',
                    7,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(context, Icons.task_alt, 'Task', 8, isDrawer: isDrawer),
                  _buildSidebarItem(context, Icons.call, 'Call', 9, isDrawer: isDrawer),
                  _buildSidebarItem(
                    context,
                    Icons.share_outlined,
                    'Social Integrations',
                    10,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    context,
                    Icons.payments_outlined,
                    'Payments Infrastructure',
                    11,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    context,
                    Icons.hub_outlined,
                    'MasterPage',
                    12,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    context,
                    Icons.cloud_outlined,
                    'Google Integrations',
                    13,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    context,
                    Icons.speed_outlined,
                    'Speed to Lead',
                    14,
                    isDrawer: isDrawer,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    {bool isDrawer = false}
  ) {
    final isSelected = widget.activeIndex == index;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 1000;

    // If matches mobile, we are in drawer (always expanded items).
    // If desktop and closed, show collapsed rail.
    if (!_isSidebarOpen && !isMobile) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: IconButton(
            icon: Icon(
              icon,
              color: isSelected ? const Color(0xFFCE9799) : Colors.white54,
            ),
            onPressed: () {
              if (isDrawer) {
                Navigator.of(context).pop(); // Close drawer on mobile
              }
              _handleNavigation(index);
            },
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: isSelected
          ? BoxDecoration(
              border: Border(
                left: BorderSide(color: const Color(0xFFCE9799), width: 3),
              ),
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(206, 151, 153, 0.1),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            )
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFFCE9799) : Colors.white54,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () {
          if (isDrawer) {
            Navigator.of(context).pop(); // Close drawer on mobile
          }
          _handleNavigation(index);
        },
      ),
    );
  }

  void _handleNavigation(int index) {
    // TODO: Re-enable when screens are implemented
    if (widget.isBroker) {
      // if (index == 0 && widget.activeIndex != 0) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const BrokerDashboardScreen(),
      //     ),
      //   );
      // } else if (index == 1 && widget.activeIndex != 1) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => const CreateTaskPackScreen()),
      //   );
      // } else if (index == 2 && widget.activeIndex != 2) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const BrokerIntelligenceScreen(),
      //     ),
      //   );
      // } else if (index == 3 && widget.activeIndex != 3) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const TeamPerformanceScreen(),
      //     ),
      //   );
      // } else if (index == 4 && widget.activeIndex != 4) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const BrokerLeadOverviewScreen(),
      //     ),
      //   );
      // } else if (index == 5 && widget.activeIndex != 5) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => const BrokerWalletScreen()),
      //   );
      // }
    } else {
      if (index == 0 && widget.activeIndex != 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutWrapper(activeIndex: 0)),
        );
      } else if (index == 1 && widget.activeIndex != 1) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => const PropertiesScreen()),
      //   );
      } else if (index == 2 && widget.activeIndex != 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutWrapper(activeIndex: 2)),
        );
      } else if (index == 5 && widget.activeIndex != 5) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => const AutomationScreen()),
      //   );
      } else if (index == 3 && widget.activeIndex != 3) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => const AgreementScreen()),
      //   );
      } else if (index == 8 && widget.activeIndex != 8) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => const TaskDetailScreen()),
      //   );
      } else if (index == 9 && widget.activeIndex != 9) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => const CallReportScreen()),
      //   );
      } else if (index == 10 && widget.activeIndex != 10) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutWrapper(activeIndex: 10)),
        );
      } else if (index == 11 && widget.activeIndex != 11) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutWrapper(activeIndex: 11)),
        );
      } else if (index == 12 && widget.activeIndex != 12) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutWrapper(activeIndex: 12)),
        );
      } else if (index == 13 && widget.activeIndex != 13) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutWrapper(activeIndex: 13)),
        );
      } else if (index == 14 && widget.activeIndex != 14) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutWrapper(activeIndex: 14)),
        );
      }
    }
  }
}

class MainLayoutWrapper extends StatelessWidget {
  final int activeIndex;
  final bool isBroker;

  const MainLayoutWrapper({
    super.key,
    required this.activeIndex,
    this.isBroker = false,
  });

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      activeIndex: activeIndex,
      isBroker: isBroker,
      title: _getTitleForIndex(activeIndex),
      child: _getScreenForIndex(activeIndex),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Properties';
      case 2:
        return 'Wallet';
      case 3:
        return 'Agreements';
      case 4:
        return 'Files';
      case 5:
        return 'Automation';
      case 6:
        return 'Settings';
      case 7:
        return 'Admin';
      case 8:
        return 'Task';
      case 9:
        return 'Call';
      case 10:
        return 'Social Integrations';
      case 11:
        return 'Payments & Infrastructure Integrations';
      case 12:
        return 'MasterPage';
      case 13:
        return 'Google Integrations';
      case 14:
        return 'Speed to Lead';
      default:
        return 'Realtor OS';
    }
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return DashboardScreen();
      case 1:
        // TODO: Replace with PropertiesScreen when implemented
        return const Center(
          child: Text(
            'Properties Screen',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        );
      case 2:
        return const WalletScreen();
      case 3:
        // TODO: Replace with AgreementScreen when implemented
        return const Center(
          child: Text(
            'Agreements Screen',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        );
      case 4:
        // TODO: Replace with FilesScreen when implemented
        return const Center(
          child: Text(
            'Files Screen',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        );
      case 5:
        // TODO: Replace with AutomationScreen when implemented
        return const Center(
          child: Text(
            'Automation Screen',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        );
      case 6:
        // TODO: Replace with SettingsScreen when implemented
        return const Center(
          child: Text(
            'Settings Screen',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        );
      case 7:
        // TODO: Replace with AdminScreen when implemented
        return const Center(
          child: Text(
            'Admin Screen',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        );
      case 8:
        // TODO: Replace with TaskScreen when implemented
        return const Center(
          child: Text(
            'Task Screen',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        );
      case 9:
        // TODO: Replace with CallScreen when implemented
        return const Center(
          child: Text(
            'Call Screen',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        );
      case 10:
        return const SocialMediaIntegrationsScreen(userId: 'demo-user');
      case 11:
        return const PaymentsInfrastructureIntegrationsScreen();
      case 12:
        return const MasterPageScreen();
      case 13:
        return const GoogleIntegrationsScreen();
      case 14:
        return const SpeedToLeadScreenWrapper();
      default:
        return DashboardScreen();
    }
  }
}

class SpeedToLeadScreenWrapper extends StatefulWidget {
  const SpeedToLeadScreenWrapper({super.key});

  @override
  State<SpeedToLeadScreenWrapper> createState() => _SpeedToLeadScreenWrapperState();
}

class _SpeedToLeadScreenWrapperState extends State<SpeedToLeadScreenWrapper> {
  late SpeedToLeadActivationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SpeedToLeadActivationController(
      initialState: SpeedToLeadStateModel.initial(),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate loading data
    _controller.setHeader(
      title: 'Speed-to-Lead Activation',
      subtitle: 'Respond instantly to incoming leads for maximum conversion rates',
    );
    
    _controller.setMetrics([
      SpeedToLeadMetricModel(
        id: '1',
        metricKey: SpeedToLeadMetricKey.responseTime,
        value: '2.3m',
        label: 'Avg Response Time',
      ),
      SpeedToLeadMetricModel(
        id: '2',
        metricKey: SpeedToLeadMetricKey.firstContact,
        value: '94%',
        label: 'First Contact Rate',
      ),
      SpeedToLeadMetricModel(
        id: '3',
        metricKey: SpeedToLeadMetricKey.bpaSent,
        value: '12',
        label: 'BPA Sent Today',
      ),
      SpeedToLeadMetricModel(
        id: '4',
        metricKey: SpeedToLeadMetricKey.bpaSigned,
        value: '8',
        label: 'BPA Signed Today',
      ),
      SpeedToLeadMetricModel(
        id: '5',
        metricKey: SpeedToLeadMetricKey.conversion,
        value: '67%',
        label: 'Conversion Rate',
      ),
    ]);

    _controller.setLatestLead(
      LeadArrivalModel(
        leadId: 'lead-123',
        name: 'Sarah Johnson',
        source: 'Zillow',
        phone: '+1 (555) 123-4567',
        email: 'sarah.johnson@email.com',
        receivedAtLabel: '2 min ago',
      ),
    );

    _controller.setCtas(
      primaryLabel: 'Activate AI Call',
      secondaryLabel: 'Route to Action Plan',
      primaryEnabled: true,
      secondaryEnabled: true,
    );

    _controller.setBottomNote(
      'AI calls are automatically recorded and transcribed for compliance purposes.',
    );

    _controller.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return SpeedToLeadActivationScreen(
          state: _controller.state,
          onRefresh: _loadData,
          onPrimaryCta: (leadId) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('AI Call activated for lead: $leadId')),
            );
          },
          onSecondaryCta: (leadId) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Routed to action plan: $leadId')),
            );
          },
        );
      },
    );
  }
}