import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import '../utils/app_styles.dart';
import '../widgets/user_widgets.dart';
import '../models/agent_profile_card_stats.dart';
import '../models/user_list_item.dart';
import '../services/user_service.dart';

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
  
  // Profile card stats (not displayed, but RPC still called)
  AgentProfileCardStats? _profileStats;
  bool _isLoadingStats = false;
  String? _statsError;

  // User list data from RPC - preserved source state
  List<UserRowData> _allUsersFromRpc = [];
  bool _isLoadingUsers = false;
  String? _usersError;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _usersError = null;
    });

    try {
      final users = await _userService.getUsersList();
      if (!mounted) return;
      
      setState(() {
        _allUsersFromRpc = users.map((user) => user.toUserRowData()).toList();
        _isLoadingUsers = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _usersError = e.toString().replaceAll('Exception: ', '');
        _isLoadingUsers = false;
      });
    }
  }

  // Derived filtered state - computed from preserved source
  List<UserRowData> get _filteredUsers {
    return _allUsersFromRpc.where((user) {
      final matchesSearch =
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRole == null || user.role == _selectedRole;
      final matchesStatus =
          _selectedStatus == null || user.status == _selectedStatus;
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
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
        // Profile Card - Render guard: disabled for list-only view
        if (false && _profileStats != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: _buildProfileCard(_profileStats!),
          ),
          const Divider(height: 0, color: AppStyles.borderSoft),
        ] else if (false && _isLoadingStats) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppStyles.panelColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppStyles.borderSoft),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          const Divider(height: 0, color: AppStyles.borderSoft),
        ] else if (false && _statsError != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppStyles.panelColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Failed to load profile: $_statsError',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {}, // Profile card disabled
                    child: const Text('Retry', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 0, color: AppStyles.borderSoft),
        ],
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
                            ? _buildMobileList(_filteredUsers)
                            : _buildDesktopTable(_filteredUsers),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(AgentProfileCardStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyles.panelColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppStyles.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF3F4651),
                child: Text(
                  stats.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stats.email,
                      style: const TextStyle(
                        color: AppStyles.mutedText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              if (stats.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppStyles.borderSoft, height: 1),
          const SizedBox(height: 12),
          // Three-column stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _StatColumn(
                  label: 'Role',
                  value: stats.role,
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'Total Orders',
                  value: stats.totalOrders.toString(),
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'Tokens',
                  value: stats.tokens.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Last Login
          Row(
            children: [
              const Text(
                'Last Login',
                style: TextStyle(
                  color: AppStyles.mutedText,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                stats.formattedLastLogin,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
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

    // If mobile, simplify filters
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
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
      );
    }

    // Desktop
    return Container(
      color: Colors.white.withValues(alpha: 0.02),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
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
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppStyles.mutedText,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
