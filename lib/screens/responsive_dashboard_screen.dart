import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/ledger_table.dart';
import '../services/supabase_service.dart';
import '../services/new_wallet_service.dart';
import 'wallet_dashboard.dart';

class ResponsiveDashboardScreen extends StatefulWidget {
  const ResponsiveDashboardScreen({super.key});

  @override
  State<ResponsiveDashboardScreen> createState() => _ResponsiveDashboardScreenState();
}

class _ResponsiveDashboardScreenState extends State<ResponsiveDashboardScreen>
    with TickerProviderStateMixin {
  String _selectedItem = 'Wallet';
  bool _isSidebarCollapsed = false;
  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnimation;

  // Live data state (backend is source of truth; Flutter does zero math)
  bool _isLoading = true;
  String? _loadError;
  WalletDataBundle? _bundle;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _sidebarAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sidebarController, curve: Curves.easeInOut),
    );
    _loadLiveWalletData();
  }

  Future<void> _loadLiveWalletData() async {
    try {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });

      final userId = SupabaseService.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final data = await NewWalletService().loadAllWalletData(userId);

      if (!mounted) return;
      setState(() {
        _bundle = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading wallet data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadLiveWalletData();
  }

  Future<void> _runAiCleanup() async {
    try {
      final userId = SupabaseService.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final resp = await NewWalletService().executeAction(
        userId: userId,
        actionType: 'ai_cleanup',
        tokenCost: 3,
      );

      if (!resp.success || resp.taskId == null) {
        throw Exception(resp.message);
      }

      await NewWalletService().completeTask(
        taskId: resp.taskId!,
        success: true,
        outcome: 'completed',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Cleanup executed (3 tokens spent).')),
      );

      await _refreshData();
    } catch (e) {
      final msg = e.toString();
      final friendly = msg.contains('PGRST202') || msg.contains('Could not find the function')
          ? 'Backend RPC missing: execute_action / complete_task. Deploy the wallet schema SQL (create_new_wallet_schema.sql / update_wallet_commitments_logic.sql) to Supabase.'
          : 'Failed to execute AI Cleanup: $e';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendly)),
      );
    }
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.bgDeep,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.accent),
              const SizedBox(height: 16),
              Text(
                'Loading wallet data...',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_loadError != null || _bundle == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgDeep,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppTheme.textSecondary, size: 28),
                const SizedBox(height: 12),
                Text(
                  'Could not load wallet data',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _loadError ?? 'Unknown error',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AccentButton(label: 'Retry', onPressed: _refreshData, compact: false),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.accent,
        child: ResponsiveBuilder(
          builder: (context, screenSize) {
            if (screenSize == ScreenSize.mobile) {
              return _buildMobileLayout();
            }
            return _buildDesktopLayout();
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDeep,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'OST',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Realtor OS',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.textPrimary),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WalletDashboard()),
              );
            },
            tooltip: 'Wallet Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.textPrimary),
            onPressed: () => _showMobileMenu(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 16),
            _buildMiniLedger(),
            const SizedBox(height: 16),
            _buildActiveCommitments(),
            const SizedBox(height: 16),
            _buildFullLedger(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar
        SidebarNavigation(
          selectedItem: _selectedItem,
          onItemSelected: (item) => setState(() => _selectedItem = item),
          isCollapsed: _isSidebarCollapsed,
        ),
        
        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: ResponsiveHelper.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with toggle button
                Row(
                  children: [
                    if (!ResponsiveHelper.isMobile(context)) ...[
                      IconButton(
                        icon: Icon(
                          _isSidebarCollapsed ? Icons.menu_open : Icons.menu,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: _toggleSidebar,
                      ),
                      const SizedBox(width: 8),
                    ],
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (!ResponsiveHelper.isMobile(context))
                      IconButton(
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const WalletDashboard()),
                          );
                        },
                        tooltip: 'Wallet Dashboard',
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.accent.withOpacity(0.1),
                          foregroundColor: AppTheme.accent,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Top Row
                ResponsiveBuilder(
                  builder: (context, screenSize) {
                    if (screenSize == ScreenSize.desktop) {
                      return Row(
                        children: [
                          Expanded(flex: 2, child: _buildBalanceCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildMiniLedger()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildActiveCommitments()),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildBalanceCard(),
                          const SizedBox(height: 16),
                          _buildMiniLedger(),
                          const SizedBox(height: 16),
                          _buildActiveCommitments(),
                        ],
                      );
                    }
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Bottom Row - Full Ledger + Right Sidebar
                ResponsiveBuilder(
                  builder: (context, screenSize) {
                    if (screenSize == ScreenSize.desktop) {
                      return Row(
                        children: [
                          Expanded(flex: 3, child: _buildFullLedger()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildRightSidebar()),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildFullLedger(),
                          const SizedBox(height: 16),
                          _buildRightSidebar(),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    final available = _bundle!.health.availableTokens;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'OST',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Execution Balance',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${available.toString()} OST',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Mini chart
          SizedBox(
            height: 60,
            child: _BalanceChart(),
          ),
          const SizedBox(height: 12),
          Text(
            'Tokens are consumed only when actions execute.',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniLedger() {
    final txs = _bundle!.transactions;
    final rows = txs.take(3).map((tx) {
      final date = tx.createdAt.toIso8601String().substring(0, 10);
      return LedgerRow(
        date: date,
        actionType: tx.displayLabel,
        dealLead: tx.source,
        fundingBadge: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.18),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${tx.amount} tokens',
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }).toList();

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Execution Ledger'),
          const SizedBox(height: 16),
          LedgerTable(rows: rows, compact: true),
          const SizedBox(height: 12),
          Text(
            '+${txs.length} entries logged in last 30 days',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCommitments() {
    final commitments = _bundle!.commitments;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Active Commitments'),
          const SizedBox(height: 16),
          if (commitments.isEmpty)
            Text(
              'No active commitments',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
            )
          else ...[
            ...commitments.take(4).map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CommitmentItem(
                  title: c.displayLabel,
                  tokens: '${c.totalReservedAmount} tokens reserved',
                  progress: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullLedger() {
    final txs = _bundle!.transactions;
    final rows = txs.take(10).map((tx) {
      final date = tx.createdAt.toIso8601String().substring(0, 10);
      return LedgerRow(
        date: date,
        actionType: tx.displayLabel,
        dealLead: tx.source,
        fundingSource: '—',
        outcome: '—',
      );
    }).toList();

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Execution Ledger'),
          const SizedBox(height: 16),
          LedgerTable(rows: rows),
        ],
      ),
    );
  }

  Widget _buildRightSidebar() {
    return Column(
      children: [
        _buildRecommendedInterventions(),
        const SizedBox(height: 16),
        _buildWalletHealthCard(),
      ],
    );
  }

  Widget _buildRecommendedInterventions() {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Recommended Interventions'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3 stalled buyers detected - activate AI call cleanup (3 tokens)',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                AccentButton(
                  label: 'Activate AI Cleanup',
                  onPressed: _runAiCleanup,
                  compact: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1 deal at risk - live transfer recommended (10 tokens)',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                AccentButton(
                  label: 'Escalate to Live Call',
                  onPressed: () {},
                  compact: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletHealthCard() {
    final health = _bundle!.health;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Wallet Health'),
          const SizedBox(height: 16),
          _WalletMetric(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Available Tokens',
            value: health.availableTokens.toString(),
            color: AppTheme.accent,
            subtitle: 'Ready to use',
          ),
          const SizedBox(height: 16),
          _WalletMetric(
            icon: Icons.lock_outline,
            label: 'Reserved (Commitments)',
            value: health.reservedTokens.toString(),
            color: Colors.orange,
            subtitle: 'Locked for active tasks',
          ),
          const SizedBox(height: 16),
          _WalletMetric(
            icon: Icons.history_outlined,
            label: 'Tokens Spent (Last 30 Days)',
            value: health.tokensSpentLast30Days.toString(),
            color: Colors.red,
            subtitle: 'Completed transactions',
          ),
          const SizedBox(height: 16),
          _WalletMetric(
            icon: Icons.schedule_outlined,
            label: 'Expiring Soon (Next 7 Days)',
            value: health.expiringNext7Days.toString(),
            color: Colors.amber,
            subtitle: 'From available balance',
          ),
        ],
      ),
    );
  }

  Widget _buildTrustLevelCard() {
    final trust = _bundle!.trust;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Operational Trust Level'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Operational Trust Level ${trust.currentLevel}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Next Level ${trust.nextLevel} (${trust.progressPercent}%)',
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: trust.progressPercent / 100,
                  backgroundColor: AppTheme.bgCardHover,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Navigation',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ...['Dashboard', 'Properties', 'Wallet', 'Agreements', 'Files', 'Automation', 'Settings', 'Admin', 'Task', 'Call'].map((item) => 
              ListTile(
                title: Text(
                  item,
                  style: TextStyle(
                    color: _selectedItem == item ? AppTheme.accent : AppTheme.textPrimary,
                    fontWeight: _selectedItem == item ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                trailing: _selectedItem == item 
                    ? Icon(Icons.check, color: AppTheme.accent, size: 20)
                    : null,
                onTap: () {
                  setState(() => _selectedItem = item);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommitmentItem extends StatelessWidget {
  const _CommitmentItem({
    required this.title,
    required this.tokens,
    required this.progress,
  });

  final String title;
  final String tokens;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.textMuted,
                    size: 12,
                  ),
                ],
              ),
            ),
            Text(
              tokens,
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (progress > 0)
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.bgCardHover,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
          ),
      ],
    );
  }
}

class _WalletMetric extends StatelessWidget {
  const _WalletMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 30),
              const FlSpot(1, 45),
              const FlSpot(2, 35),
              const FlSpot(3, 50),
              const FlSpot(4, 42),
              const FlSpot(5, 65),
              const FlSpot(6, 55),
            ],
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.accent.withOpacity(0.8),
                AppTheme.accent.withOpacity(0.4),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.accent.withOpacity(0.3),
                  AppTheme.accent.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 80,
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}
