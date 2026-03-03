import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../models/task_overview.dart';
import '../models/nav_tab.dart';
import '../services/task_service.dart';
import '../services/user_service.dart';
import '../services/navigation_service.dart';
import '../services/supabase_service.dart';
import '../widgets/profile_header.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/task_table.dart';
import '../widgets/task_overview_panel.dart';
import 'agent_wallet_screen.dart';

class TasksQueueScreen extends StatefulWidget {
  const TasksQueueScreen({super.key});

  @override
  State<TasksQueueScreen> createState() => _TasksQueueScreenState();
}

class _TasksQueueScreenState extends State<TasksQueueScreen> {
  final TaskService _taskService = TaskService();
  final UserService _userService = UserService();
  final NavigationService _navService = NavigationService();

  List<Task> _tasks = [];
  TaskOverview? _overview;
  User? _user;
  List<NavTab> _navTabs = [];
  String _selectedTabId = 'tasks';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Verify authentication before making RPC calls
    final client = SupabaseService.instance.client;
    final currentUser = client.auth.currentUser;
    final session = client.auth.currentSession;
    
    debugPrint('🔍 Checking authentication before loading data...');
    debugPrint('Current user: ${currentUser?.email ?? "null"}');
    debugPrint('User ID: ${currentUser?.id ?? "null"}');
    debugPrint('Session exists: ${session != null}');
    
    if (currentUser == null || session == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not authenticated. Please sign in first.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required. Please restart the app.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _taskService.getTasks(),
        _taskService.getTaskOverview(),
        _userService.getAgentProfileHeader(),
        _navService.getAgentNavTabs(),
        _navService.getActiveTabState(),
      ]);

      final tasks = results[0] as List<Task>;
      final overview = results[1] as TaskOverview;
      final user = results[2] as User;
      final navTabs = results[3] as List<NavTab>;
      final activeTab = results[4] as String;

      setState(() {
        _tasks = tasks;
        _overview = overview;
        _user = user;
        _navTabs = navTabs;
        _selectedTabId = activeTab;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ [Screen] Error loading data: $e');
      debugPrint('   Stack trace: $stackTrace');
      
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _handleTaskTap(Task task) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6B35),
        ),
      ),
    );

    try {
      // Fetch full task detail from RPC
      // Task.id is already a String (UUID), so use it directly
      debugPrint('🔍 [Screen] Fetching task detail for ID: ${task.id}');
      final taskDetail = await _taskService.getTaskDetail(task.id);

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading

      // Show task details dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            taskDetail.title,
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Task ID', taskDetail.id),
                _buildDetailRow('Category', taskDetail.category),
                _buildDetailRow('Status', taskDetail.status),
                _buildDetailRow('Description', taskDetail.description),
                _buildDetailRow('Token Cost', taskDetail.tokenCost.toString()),
                _buildDetailRow('XP Reward', taskDetail.xpReward.toString()),
                _buildDetailRow('Created', taskDetail.createdAt),
                _buildDetailRow('Updated', taskDetail.updatedAt),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading task detail: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Realtor OS title
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
              child: Row(
                children: [
                  const Text(
                    'Realtor OS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Profile Header
            if (_user != null) ProfileHeader(user: _user!),
            // Navigation Bar
            if (_navTabs.isNotEmpty)
              AppNavigationBar(
                navTabs: _navTabs,
                selectedTabId: _selectedTabId,
                onItemSelected: (tabId) {
                      if (tabId == 'wallet') {
                        // Navigate to Wallet screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AgentWalletScreen(),
                          ),
                        );
                  } else {
                    // Update selected tab for other tabs
                    setState(() {
                      _selectedTabId = tabId;
                    });
                  }
                },
              ),
            // Main Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B35),
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error: $_errorMessage',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : isMobile
                          ? _buildMobileLayout()
                          : _buildDesktopLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Table
          Expanded(
            flex: 3,
            child: TaskTable(
              tasks: _tasks,
              onTaskTap: _handleTaskTap,
            ),
          ),
          const SizedBox(width: 24),
          // Task Overview Panel
          SizedBox(
            width: 300,
            child: _overview != null
                ? TaskOverviewPanel(overview: _overview!)
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Task Overview Panel (on top for mobile)
          if (_overview != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TaskOverviewPanel(overview: _overview!),
            ),
          // Task Table
          TaskTable(
            tasks: _tasks,
            onTaskTap: _handleTaskTap,
          ),
        ],
      ),
    );
  }
}
