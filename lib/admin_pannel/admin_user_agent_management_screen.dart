import 'package:demo/admin_pannel/shared_admin_navigation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/user_service.dart';
import '../services/supabase_service.dart';
import '../models/user_list_item.dart';


// ─────────────────────────────────────────────────────
// COLOR PALETTE — dark gunmetal + copper accent
// ─────────────────────────────────────────────────────
class AppColors {
  static const background     = Color(0xFF141414);
  static const surfaceDeep   = Color(0xFF1C1C1C);
  static const surfaceMid    = Color(0xFF222222);
  static const surfaceLight  = Color(0xFF2A2A2A);
  static const border        = Color(0xFF2F2F2F);
  static const borderAccent  = Color(0xFF3A3A3A);
  static const copper        = Color(0xFFB87333);
  static const copperGlow    = Color(0xFFD4884A);
  static const copperDim     = Color(0xFF8B5A2B);
  static const textPrimary   = Color(0xFFE8E0D8);
  static const textSecondary = Color(0xFF8A8278);
  static const textMuted     = Color(0xFF555050);
  static const selectedNav   = Color(0xFF2C2420);
  static const agentBadge    = Color(0xFF2B2010);
  static const agentText     = Color(0xFFB87333);
  static const rowSelected   = Color(0xFF251E18);
  static const rowHover      = Color(0xFF202020);
  static const iconColor     = Color(0xFF6B6460);
  static const statusGreen   = Color(0xFF4CAF50);
  static const statusGray    = Color(0xFF757575);
}

// ─────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────
class UserRecord {
  final String name;
  final String email;
  final String role;   // '' | 'Agent'
  final String status; // Active | Running | Idle | Inactive
  final String lastLogin;
  final String totalOrders;
  final String tokenBalance;
  final bool isSelected;
  final bool hasActions;

  const UserRecord({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastLogin,
    required this.totalOrders,
    required this.tokenBalance,
    this.isSelected = false,
    this.hasActions = false,
  });
}

// ─────────────────────────────────────────────────────
// ROOT SCREEN
// ─────────────────────────────────────────────────────
class AdminUserAgentManagementScreen extends StatefulWidget {
  const AdminUserAgentManagementScreen({super.key});

  @override
  State<AdminUserAgentManagementScreen> createState() => _ScreenState();
}

class _ScreenState extends State<AdminUserAgentManagementScreen> {
  int _navIndex = 1;
  int? _hoveredRow;
  final _search = TextEditingController();
  
  // Live data management
  final UserService _userService = UserService();
  List<UserListItem> _allUsers = [];
  bool _isLoadingUsers = false;
  String? _usersError;
  
  RealtimeChannel? _usersChannel;
  Timer? _refreshTimer;
  DateTime? _lastUpdateTime;
  bool _isLiveConnected = false;
  String? _connectionError;
  static const Duration _refreshInterval = Duration(seconds: 30);
  
  String _searchQuery = '';
  String? _selectedRole;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _setupRealtimeSubscription();
    _setupPeriodicRefresh();
    
    // Add search listener
    _search.addListener(() {
      setState(() {
        _searchQuery = _search.text;
      });
    });
  }

  @override
  void dispose() {
    _usersChannel?.unsubscribe();
    _refreshTimer?.cancel();
    _search.dispose();
    super.dispose();
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
        _allUsers = users;
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
      
      _usersChannel = client.channel('admin:users')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'users',
          callback: (payload) {
            debugPrint('🔄 [Admin Realtime] Users table changed: ${payload.eventType}');
            _handleRealtimeUpdate(payload);
          },
        )
        .subscribe();
      
      setState(() {
        _isLiveConnected = true;
        _connectionError = null;
      });
      
      debugPrint('✅ [Admin Realtime] Subscribed to users table changes');
    } catch (e) {
      debugPrint('❌ [Admin Realtime] Failed to subscribe: $e');
      setState(() {
        _isLiveConnected = false;
        _connectionError = e.toString();
      });
    }
  }

  /// Handle real-time updates from users table
  void _handleRealtimeUpdate(PostgresChangePayload payload) {
    if (!mounted) return;
    _loadUsers();
  }

  /// Setup periodic refresh as fallback
  void _setupPeriodicRefresh() {
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
      if (mounted) {
        debugPrint('🔄 [Admin Periodic] Refreshing users list...');
        _loadUsers();
      }
    });
  }

  // Filter users based on search and filters
  List<UserListItem> get _filteredUsers {
    return _allUsers.where((user) {
      final matchesSearch =
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRole == null || user.role == _selectedRole;
      final matchesStatus =
          _selectedStatus == null || user.status == _selectedStatus;
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  // Build live status indicator
  Widget _buildLiveStatus() {
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
              '• ${_formatLastUpdate(_lastUpdateTime!)}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatLastUpdate(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Vignette
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.4,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                  ),
                ),
              ),
            ),
          ),
          // Copper top border
          const Positioned(top: 0, left: 0, right: 0, child: _CopperLine()),
          // Copper bottom border
          const Positioned(bottom: 0, left: 0, right: 0, child: _CopperLine()),
          // Main layout
          Row(
            children: [
              SharedAdminNavigation(
                selectedIndex: _navIndex,
                onSelect: (i) => setState(() => _navIndex = i),
              ),
              Expanded(
                child: _ContentArea(
                  search: _search,
                  isLoading: _isLoadingUsers,
                  error: _usersError,
                  users: _filteredUsers.map((user) => UserRecord(
                    name: user.name,
                    email: user.email,
                    role: user.role == 'agent' ? 'Agent' : '',
                    status: user.status == 'active' ? 'Active' : 
                           user.status == 'suspended' ? 'Inactive' : 
                           user.status,
                    lastLogin: user.formattedLastLogin,
                    totalOrders: user.totalOrders.toString(),
                    tokenBalance: user.tokenBalance.toString(),
                    hasActions: true,
                  )).toList(),
                  hoveredRow: _hoveredRow,
                  onHoverRow: (i) => setState(() => _hoveredRow = i),
                  liveStatus: _buildLiveStatus(),
                  connectionError: _connectionError,
                  onRetry: () => _setupRealtimeSubscription(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// CONTENT AREA
// ─────────────────────────────────────────────────────
class _ContentArea extends StatelessWidget {
  final TextEditingController search;
  final bool isLoading;
  final String? error;
  final List<UserRecord> users;
  final int? hoveredRow;
  final ValueChanged<int?> onHoverRow;
  final Widget liveStatus;
  final String? connectionError;
  final VoidCallback onRetry;

  const _ContentArea({
    required this.search,
    required this.isLoading,
    required this.error,
    required this.users,
    required this.hoveredRow,
    required this.onHoverRow,
    required this.liveStatus,
    required this.connectionError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text('User & Agent Management',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.6,
                      )),
                ),
                liveStatus,
                const SizedBox(width: 12),
                _OutlineButton(label: 'Filters'),
              ],
            ),
          ),
          // ── Filter bar
          Row(
            children: [
              Expanded(child: _SearchBox(controller: search)),
              const SizedBox(width: 8),
              _DropChip(label: 'Role'),
              const SizedBox(width: 6),
              _DropChip(label: 'Status'),
              const SizedBox(width: 6),
              _OutlineButton(label: 'More Filters'),
            ],
          ),
          const SizedBox(height: 16),
          // Connection error display
          if (connectionError != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Live connection failed. Using periodic refresh.',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // ── Table
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.copper),
                        SizedBox(height: 16),
                        Text(
                          'Loading users...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading users',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: onRetry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.copper,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : users.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  color: AppColors.textMuted,
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No users found',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search or filters',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _DataTable(
                            users: users,
                            hoveredRow: hoveredRow,
                            onHoverRow: onHoverRow,
                          ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// SEARCH BOX
// ─────────────────────────────────────────────────────
class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        onChanged: (value) {
          // This will trigger filtering through the listener in initState
        },
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textMuted),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                  onPressed: () {
                    controller.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceMid,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.copper, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 9),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// SMALL UI BUTTONS
// ─────────────────────────────────────────────────────
class _DropChip extends StatelessWidget {
  final String label;
  const _DropChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 5),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  const _OutlineButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// DATA TABLE
// ─────────────────────────────────────────────────────
const _cols = ['Name', 'Email', 'Role', 'Status', 'Last Login', 'Total Orders', 'Token Balance', 'Flags'];
const _cw   = [  155.0, 190.0,   88.0,    108.0,        96.0,          108.0,           118.0,   130.0 ];

class _DataTable extends StatelessWidget {
  final List<UserRecord> users;
  final int? hoveredRow;
  final ValueChanged<int?> onHoverRow;

  const _DataTable({
    required this.users,
    required this.hoveredRow,
    required this.onHoverRow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _HeaderRow(),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, i) => _DataRow(
                user: users[i],
                index: i,
                isHovered: hoveredRow == i,
                onHover: (v) => onHoverRow(v ? i : null),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // checkbox
            SizedBox(
              width: 32,
              child: Transform.scale(
                scale: 0.85,
                child: Checkbox(
                  value: false,
                  onChanged: (_) {},
                  side: const BorderSide(color: AppColors.borderAccent, width: 1.5),
                  fillColor: WidgetStateProperty.all(Colors.transparent),
                ),
              ),
            ),
            ..._cols.asMap().entries.map((e) {
              final isSorted = e.key == 0;
              return SizedBox(
                width: _cw[e.key],
                child: Row(
                  children: [
                    Text(e.value,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        )),
                    if (isSorted) ...[
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_upward_rounded, size: 11, color: AppColors.copper),
                    ],
                  ],
                ),
              );
            }),
            // extra dots col
            const Icon(Icons.more_horiz, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final UserRecord user;
  final int index;
  final bool isHovered;
  final ValueChanged<bool> onHover;

  const _DataRow({
    required this.user,
    required this.index,
    required this.isHovered,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final bg = user.isSelected
        ? AppColors.rowSelected
        : isHovered
        ? AppColors.rowHover
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        color: bg,
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // checkbox
                    SizedBox(
                      width: 32,
                      child: Transform.scale(
                        scale: 0.85,
                        child: Checkbox(
                          value: user.isSelected,
                          onChanged: (_) {},
                          side: const BorderSide(color: AppColors.borderAccent, width: 1.5),
                          fillColor: WidgetStateProperty.resolveWith((s) =>
                          s.contains(WidgetState.selected)
                              ? AppColors.copper
                              : Colors.transparent),
                        ),
                      ),
                    ),
                    // Name
                    SizedBox(
                      width: _cw[0],
                      child: Row(
                        children: [
                          Container(
                            width: 3, height: 3,
                            decoration: BoxDecoration(
                              color: user.isSelected ? AppColors.copper : AppColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(user.name,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    // Email
                    SizedBox(
                      width: _cw[1],
                      child: Text(user.email,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ),
                    // Role
                    SizedBox(
                      width: _cw[2],
                      child: user.role.isNotEmpty
                          ? Text(user.role,
                          style: const TextStyle(
                            color: AppColors.agentText,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ))
                          : const Text('–', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ),
                    // Status
                    SizedBox(
                      width: _cw[3],
                      child: _StatusCell(status: user.status),
                    ),
                    // Last login
                    SizedBox(
                      width: _cw[4],
                      child: Text(user.lastLogin,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ),
                    // Total orders — show actual value
                    SizedBox(
                      width: _cw[5],
                      child: Text(
                        user.totalOrders,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Token balance — actual value
                    SizedBox(
                      width: _cw[6],
                      child: Text(
                        user.tokenBalance,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Flags / actions
                    SizedBox(
                      width: _cw[7],
                      child: user.hasActions
                          ? const _RowActions()
                          : const Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(Icons.more_horiz, size: 14, color: AppColors.textMuted)),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border, indent: 0),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// CELL WIDGETS
// ─────────────────────────────────────────────────────
class _AgentBadge extends StatelessWidget {
  final String label;
  const _AgentBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),

      child: Text(label,
          style: const TextStyle(
            color: AppColors.agentText,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          )),
    );
  }
}

class _StatusCell extends StatelessWidget {
  final String status;
  const _StatusCell({required this.status});

  Color get _dot {
    switch (status) {
      case 'Active':   return AppColors.statusGreen;
      case 'Running':  return AppColors.copper;
      case 'Idle':     return AppColors.statusGray;
      case 'Inactive': return const Color(0xFF444444);
      default:         return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 6, height: 6,
        ),
        const SizedBox(width: 7),
        Text(status, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _DashBar extends StatelessWidget {
  const _DashBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30, height: 2,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBtn(icon: Icons.search_rounded),
        const SizedBox(width: 8),
        _IconBtn(icon: Icons.lock_outline_rounded),
        const SizedBox(width: 8),
        _IconBtn(icon: Icons.crop_square_rounded),
        const SizedBox(width: 8),
        const Icon(Icons.more_horiz, size: 14, color: AppColors.iconColor),
      ],
    );
  }
}

class _IconBtn extends StatefulWidget {
  final IconData icon;
  const _IconBtn({required this.icon});
  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: Icon(widget.icon,
          size: 14, color: _h ? AppColors.copper : AppColors.iconColor),
    );
  }
}

// ─────────────────────────────────────────────────────
// DECORATIVE
// ─────────────────────────────────────────────────────
class _CopperLine extends StatelessWidget {
  const _CopperLine();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.5,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.copperDim,
            AppColors.copper,
            AppColors.copperGlow,
            AppColors.copper,
            AppColors.copperDim,
            Colors.transparent,
          ],
          stops: [0.0, 0.15, 0.35, 0.5, 0.65, 0.85, 1.0],
        ),
      ),
    );
  }
}