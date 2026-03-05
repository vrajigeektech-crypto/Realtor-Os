import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../layout/main_layout.dart';
import '../utils/app_styles.dart';
import '../widgets/user_widgets.dart';
import '../widgets/enhanced_user_widgets.dart';
import '../services/user_service.dart';
import '../services/supabase_service.dart';
import '../models/enhanced_user_list_item.dart';

/// Realtor OS – User & Agent Management Screen
/// Responsive: Switch to Cards on Mobile, Table on Desktop.
class UserAgentManagementScreen extends StatefulWidget {
  const UserAgentManagementScreen({super.key});

  @override
  State<UserAgentManagementScreen> createState() =>
      _UserAgentManagementScreenState();
}

class _UserAgentManagementScreenState extends State<UserAgentManagementScreen> {
  final UserService _userService = UserService();
  
  String _searchQuery = '';
  String? _selectedRole;
  String? _selectedStatus;
  
  // User list data from RPC - preserved source state
  List<EnhancedUserListItem> _allUsersFromRpc = [];
  bool _isLoadingUsers = false;
  String? _usersError;

  // View mode: 'simple' or 'enhanced'
  String _viewMode = 'simple';

  // Live data management
  RealtimeChannel? _usersChannel;
  Timer? _refreshTimer;
  DateTime? _lastUpdateTime;
  bool _isLiveConnected = false;
  String? _connectionError;
  static const Duration _refreshInterval = Duration(seconds: 30); // Fallback refresh

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _setupRealtimeSubscription();
    _setupPeriodicRefresh();
  }

  @override
  void dispose() {
    _usersChannel?.unsubscribe();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _usersError = null;
    });

    try {
      final users = await _userService.getEnhancedUsersList();
      if (!mounted) return;
      
      setState(() {
        _allUsersFromRpc = users;
        _isLoadingUsers = false;
        _lastUpdateTime = DateTime.now();
        _connectionError = null;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _usersError = e.toString().replaceAll('Exception: ', '');
        _isLoadingUsers = false;
        _connectionError = _usersError;
      });
    }
  }

  /// Setup real-time subscription to users table
  void _setupRealtimeSubscription() {
    try {
      final client = SupabaseService.instance.client;
      
      _usersChannel = client.channel('public:users')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'users',
          callback: (payload) {
            debugPrint('🔄 [Realtime] Users table changed: ${payload.eventType}');
            _handleRealtimeUpdate(payload);
          },
        )
        .subscribe();
      
      setState(() {
        _isLiveConnected = true;
        _connectionError = null;
      });
      
      debugPrint('✅ [Realtime] Subscribed to users table changes');
    } catch (e) {
      debugPrint('❌ [Realtime] Failed to subscribe: $e');
      setState(() {
        _isLiveConnected = false;
        _connectionError = e.toString();
      });
    }
  }

  /// Handle real-time updates from users table
  void _handleRealtimeUpdate(PostgresChangePayload payload) {
    if (!mounted) return;
    
    // Refresh the entire users list when any change occurs
    _loadUsers();
  }

  /// Setup periodic refresh as fallback
  void _setupPeriodicRefresh() {
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
      if (mounted) {
        debugPrint('🔄 [Periodic] Refreshing users list...');
        _loadUsers();
      }
    });
  }

  // Derived filtered state - computed from preserved source
  List<EnhancedUserListItem> get _filteredUsers {
    return _allUsersFromRpc.where((user) {
      final matchesSearch =
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (user.phone?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesRole = _selectedRole == null || user.role == _selectedRole;
      final matchesStatus =
          _selectedStatus == null || user.status == _selectedStatus;
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  // Convert enhanced users to row data for display
  List<EnhancedUserRowData> get _enhancedRowData {
    return _filteredUsers.map((user) => EnhancedUserRowData(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.displayRole,
      status: user.displayStatus,
      lastLogin: user.formattedLastLogin,
      lastActivity: user.formattedLastActivity,
      createdDate: user.formattedCreatedDate,
      totalOrders: user.totalOrders.toString(),
      tokenBalance: user.tokensBalance.toStringAsFixed(2),
      xpTotal: user.xpTotal.toString(),
      level: user.level.toString(),
      currentStreak: user.currentStreak.toString(),
      onboardingStatus: user.isFullyOnboarded ? 'Complete' : 
                          (user.onboardingStep > 0 ? 'In Progress' : 'Not Started'),
      hasFlags: user.hasFlags,
      galleryCount: user.galleryCount.toString(),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'User Management',
      activeIndex: 1, // User Management
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return Stack(
            children: [
              _buildMainPane(isMobile),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Add User feature coming soon'),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFFCE9799),
                  icon: const Icon(Icons.add),
                  label: const Text('Add User'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- Main Pane ----------

  Widget _buildMainPane(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Expanded(
          child: Column(
            children: [
              _buildHeaderFilters(isMobile),
              const Divider(height: 0, color: AppStyles.borderSoft),
              Expanded(
                child: _isLoadingUsers
                    ? const Center(child: CircularProgressIndicator())
                    : _usersError != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Error loading users: $_usersError',
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadUsers,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : isMobile
                            ? _buildMobileList(_viewMode == 'enhanced' ? _filteredUsers.map((user) => user.toUserRowData()).toList() : _filteredUsers.map((user) => user.toUserRowData()).toList())
                            : _viewMode == 'enhanced' 
                                ? _buildEnhancedDesktopTable(_enhancedRowData)
                                : _buildDesktopTable(_filteredUsers.map((user) => user.toUserRowData()).toList()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderFilters(bool isMobile) {
    // Helper for filter chips
    Widget chipDropdown(
      String label,
      String? currentValue,
      List<String> options,
      ValueChanged<String?> onChanged,
    ) {
      return Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppStyles.panelColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppStyles.borderSoft),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentValue,
            hint: Text(
              label,
              style: const TextStyle(color: AppStyles.mutedText, fontSize: 12),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppStyles.mutedText,
              size: 18,
            ),
            dropdownColor: const Color(0xFF1E1E1E),
            style: const TextStyle(color: Colors.white, fontSize: 12),
            items: [
              DropdownMenuItem<String>(value: null, child: Text('All $label')),
              ...options.map(
                (opt) => DropdownMenuItem(value: opt, child: Text(opt)),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      );
    }

    // Search Field Widget
    Widget searchField() => Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppStyles.panelColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppStyles.borderSoft),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppStyles.mutedText, size: 17),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 12.5),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: 'Search users...',
                hintStyle: TextStyle(
                  color: AppStyles.mutedText,
                  fontSize: 12.5,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),
        ],
      ),
    );

    // Format last update time
    String formatLastUpdate(DateTime time) {
      final now = DateTime.now();
      final diff = now.difference(time);
      
      if (diff.inSeconds < 60) return '${diff.inSeconds}s';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${diff.inDays}d';
    }

    // Live status indicator widget
    Widget buildLiveStatus() {
      String statusText;
      Color statusColor;
      IconData statusIcon;
      
      if (_connectionError != null) {
        statusText = 'Connection Error';
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
      } else if (_isLiveConnected) {
        statusText = 'Live';
        statusColor = Colors.green;
        statusIcon = Icons.fiber_manual_record;
      } else {
        statusText = 'Offline';
        statusColor = Colors.orange;
        statusIcon = Icons.cloud_off;
      }
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              statusIcon,
              size: 12,
              color: statusColor,
            ),
            const SizedBox(width: 4),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_lastUpdateTime != null) ...[
              const SizedBox(width: 6),
              Text(
                '• ${formatLastUpdate(_lastUpdateTime!)}',
                style: TextStyle(
                  color: AppStyles.mutedText,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // If mobile, simplify filters
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: searchField()),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  icon: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppStyles.borderSoft),
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      color: AppStyles.mutedText,
                      size: 18,
                    ),
                  ),
                  color: const Color(0xFF1E1E1E),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      enabled: false,
                      child: Text(
                        'Filter by Role',
                        style: TextStyle(color: AppStyles.mutedText),
                      ),
                    ),
                    ...['Agent', 'Broker', 'Admin'].map(
                      (r) => PopupMenuItem(
                        value: 'Role:$r',
                        child: Text(
                          r,
                          style: TextStyle(
                            color: _selectedRole == r
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const PopupMenuItem(
                      enabled: false,
                      child: Text(
                        'Filter by Status',
                        style: TextStyle(color: AppStyles.mutedText),
                      ),
                    ),
                    ...['Active', 'Suspended'].map(
                      (s) => PopupMenuItem(
                        value: 'Status:$s',
                        child: Text(
                          s,
                          style: TextStyle(
                            color: _selectedStatus == s
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'Clear',
                      child: Text(
                        'Clear Filters',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                  onSelected: (val) {
                    if (val == 'Clear') {
                      setState(() {
                        _selectedRole = null;
                        _selectedStatus = null;
                      });
                    } else if (val.startsWith('Role:')) {
                      setState(() => _selectedRole = val.split(':')[1]);
                    } else if (val.startsWith('Status:')) {
                      setState(() => _selectedStatus = val.split(':')[1]);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            buildLiveStatus(),
            if (_connectionError != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Live connection failed. Using periodic refresh.',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _setupRealtimeSubscription();
                      },
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Desktop
    return Container(
      color: Colors.white.withValues(alpha: 0.02),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: searchField()),
              const SizedBox(width: 10),
              chipDropdown('Role', _selectedRole, [
                'Agent',
                'Broker',
                'Admin',
              ], (val) => setState(() => _selectedRole = val)),
              const SizedBox(width: 8),
              chipDropdown('Status', _selectedStatus, [
                'Active',
                'Suspended',
              ], (val) => setState(() => _selectedStatus = val)),
              const SizedBox(width: 10),
              SizedBox(
                height: 32,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppStyles.borderSoft),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _selectedRole = null;
                      _selectedStatus = null;
                    });
                  },
                  child: const Text('Reset', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              buildLiveStatus(),
              const SizedBox(width: 10),
              // View Mode Toggle
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: AppStyles.panelColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppStyles.borderSoft),
                ),
                child: Row(
                  children: [
                    _viewModeButton(
                      label: 'Simple',
                      isActive: _viewMode == 'simple',
                      onTap: () => setState(() => _viewMode = 'simple'),
                    ),
                    _viewModeButton(
                      label: 'Enhanced',
                      isActive: _viewMode == 'enhanced',
                      onTap: () => setState(() => _viewMode = 'enhanced'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_connectionError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live connection failed. Using periodic refresh every ${_refreshInterval.inSeconds}s.',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _setupRealtimeSubscription();
                    },
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Mobile View ---
  Widget _buildMobileList(List<UserRowData> users) {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(color: AppStyles.mutedText),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final row = users[index];
        return UserMobileCard(row: row);
      },
    );
  }

  // --- Desktop View ---
  Widget _buildDesktopTable(List<UserRowData> users) {
    const headers = [
      'Name',
      'Email',
      'Role',
      'Status',
      'Last Login',
      'Total Orders',
      'Token Balance',
      'Flags',
      '',
    ];

    if (users.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(color: AppStyles.mutedText),
        ),
      );
    }

    return Container(
      color: AppStyles.tableColor, // or transparent
      child: Column(
        children: [
          // Header row
          Container(
            color: Colors.white.withValues(alpha: 0.04),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                for (int i = 0; i < headers.length; i++)
                  Expanded(
                    flex: UserTableRow.flexForIndex(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: i == headers.length - 1
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Text(
                            headers[i],
                            style: const TextStyle(
                              color: AppStyles.mutedText,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (i == 0) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_up,
                              color: AppStyles.mutedText,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 0, color: AppStyles.borderSoft),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 0, color: AppStyles.borderSoft),
              itemBuilder: (context, index) {
                final row = users[index];
                return UserTableRow(row: row, selected: false);
              },
            ),
          ),
        ],
      ),
    );
  }

  // View mode button widget
  Widget _viewModeButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppStyles.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppStyles.mutedText,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // --- Enhanced Desktop View ---
  Widget _buildEnhancedDesktopTable(List<EnhancedUserRowData> users) {
    const headers = [
      'Name', 'Email', 'Phone', 'Role', 'Status', 'Last Login', 'Last Activity', 
      'Created', 'Orders', 'Tokens', 'XP', 'Level', 'Streak', 'Onboarding', 'Gallery', 'Flags', ''
    ];

    if (users.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(color: AppStyles.mutedText),
        ),
      );
    }

    return Container(
      color: AppStyles.tableColor,
      child: Column(
        children: [
          // Enhanced header row
          Container(
            color: Colors.white.withValues(alpha: 0.04),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                for (int i = 0; i < headers.length; i++)
                  Expanded(
                    flex: EnhancedUserRowData.flexForIndex(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        headers[i],
                        style: const TextStyle(
                          color: AppStyles.mutedText,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppStyles.borderSoft),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppStyles.borderSoft),
              itemBuilder: (context, index) {
                final row = users[index];
                return EnhancedUserTableRow(row: row, selected: false);
              },
            ),
          ),
        ],
      ),
    );
  }
}

