// agent_wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../widgets/wallet_action_bar.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/active_tasks_card.dart';
import '../widgets/sla_health_card.dart';
import '../widgets/agent_milestones_card.dart';
import '../widgets/transaction_ledger_table.dart';
import '../services/wallet_service.dart';
import '../models/wallet.dart';

class AgentWalletScreen extends StatefulWidget {
  const AgentWalletScreen({Key? key}) : super(key: key);

  @override
  State<AgentWalletScreen> createState() => _AgentWalletScreenState();
}

class _AgentWalletScreenState extends State<AgentWalletScreen> {
  final WalletService _walletService = WalletService();

  bool _loading = true;
  String? _walletId;
  double _walletBalance = 0.0;
  double _reservedTokens = 0.0;
  double _spentToday = 0.0;

  String _agentName = '';
  String _agentRole = '';
  String _brokerageName = '';

  int _totalTasks = 0;
  int _inProgressTasks = 0;
  int _inProgressValue = 0;
  int _awaitingApprovalTasks = 0;
  int _awaitingApprovalValue = 0;

  int _recentSlaBreaches = 0;
  int _tasksAtRisk = 0;

  int _currentXp = 0;
  int _nextLevelXp = 0;
  double _tokensEarned = 0.0;
  String _lastLnutDays = '';

  int _nextMilestoneAmount = 0;
  int _nextMilestoneDays = 0;
  bool _cardSetupComplete = false;
  String _cardLastFour = '';

  List<TransactionLedgerRow> _transactions = [];
  String _selectedTransactionTab = '24H';
  bool _loadingTransactions = false;
  String? _errorMessage;

  static const String _userId = 'c819a131-ca23-4296-a26a-aed7e430c735';

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 AgentWalletScreen initState fired');
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      debugPrint('🚀 _loadWalletData START');
      debugPrint('👤 User ID: $_userId');

      setState(() {
        _loading = true;
        _errorMessage = null;
      });

      // Step 1: Load wallets
      debugPrint('📡 [RPC] Calling get_all_wallets_for_user with userId: $_userId');
      final wallets = await _walletService.getAllWalletsForUser(_userId);
      debugPrint('✅ [RPC] get_all_wallets_for_user success: ${wallets.length} wallets');

      if (wallets.isEmpty) {
        throw Exception('No wallets returned for user');
      }

      final walletId = wallets.first.walletId;
      debugPrint('🪪 Using walletId: $walletId');

      // Steps 2-8: Call all RPCs in parallel
      debugPrint('📡 [RPC] Calling 8 RPCs in parallel');
      final results = await Future.wait([
        _walletService.getWalletBalance(walletId),
        _walletService.getWalletReservedTokens(walletId),
        _walletService.getWalletSpentToday(walletId),
        _walletService.getActiveTasksSummary(_userId),
        _walletService.getSlaMetrics(_userId),
        _walletService.getXpProgress(_userId),
        _walletService.getAgentMilestonesExtended(_userId),
        _walletService.getWalletTransactionsExtended(walletId, '24H'),
      ]);

      final balance = results[0] as int;
      final reservedTokens = results[1] as double;
      final spentToday = results[2] as double;
      final activeTasksSummary = results[3] as Map<String, dynamic>;
      final slaMetrics = results[4] as Map<String, dynamic>;
      final xpProgress = results[5] as Map<String, dynamic>;
      final milestonesExtended = results[6] as Map<String, dynamic>;
      final transactionsExtended = results[7] as List<ExtendedWalletTransaction>;

      debugPrint('✅ All RPCs completed successfully');

      setState(() {
        _walletId = walletId;
        _walletBalance = balance.toDouble();
        _reservedTokens = reservedTokens;
        _spentToday = spentToday;

        _totalTasks = (activeTasksSummary['total_tasks'] as num?)?.toInt() ?? 0;
        _inProgressTasks = (activeTasksSummary['in_progress_tasks'] as num?)?.toInt() ?? 0;
        _inProgressValue = (activeTasksSummary['in_progress_value'] as num?)?.toInt() ?? 0;
        _awaitingApprovalTasks = (activeTasksSummary['awaiting_approval_tasks'] as num?)?.toInt() ?? 0;
        _awaitingApprovalValue = (activeTasksSummary['awaiting_approval_value'] as num?)?.toInt() ?? 0;

        _recentSlaBreaches = (slaMetrics['recent_sla_breaches'] as num?)?.toInt() ?? 0;
        _tasksAtRisk = (slaMetrics['tasks_at_risk'] as num?)?.toInt() ?? 0;

        _currentXp = (xpProgress['total_xp'] as num?)?.toInt() ?? 0;
        _nextLevelXp = (xpProgress['next_level_xp'] as num?)?.toInt() ?? 0;

        _tokensEarned = (milestonesExtended['tokens_earned'] as num?)?.toDouble() ?? 0.0;
        _lastLnutDays = milestonesExtended['last_spend_label'] as String? ?? '';
        _nextMilestoneAmount = (milestonesExtended['next_milestone_amount'] as num?)?.toInt() ?? 0;
        _nextMilestoneDays = (milestonesExtended['next_milestone_days'] as num?)?.toInt() ?? 0;
        _cardSetupComplete = milestonesExtended['card_setup_complete'] as bool? ?? false;
        _cardLastFour = milestonesExtended['card_last_four'] as String? ?? '';

        _transactions = transactionsExtended.map((tx) => TransactionLedgerRow(
              date: tx.date,
              timeAgo: tx.timeAgo,
              actionType: tx.actionType,
              actor: tx.actor,
              dealLead: tx.dealLead,
              fundingSource: tx.fundingSource,
              amount: tx.amount,
              isPositive: tx.isPositive,
              outcome: tx.outcome,
            )).toList();

        _loading = false;
        _errorMessage = null;
      });

      debugPrint('✅ Wallet data loaded successfully');
    } catch (e, stack) {
      debugPrint('❌ Wallet load failed: $e');
      debugPrint('$stack');
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadTransactions(String timeFilter) async {
    if (_walletId == null) return;

    try {
      setState(() {
        _loadingTransactions = true;
      });

      debugPrint('📡 [RPC] Calling get_wallet_transactions_extended with walletId: $_walletId, filter: $timeFilter');
      final transactionsExtended = await _walletService.getWalletTransactionsExtended(_walletId!, timeFilter);
      debugPrint('✅ [RPC] get_wallet_transactions_extended success: ${transactionsExtended.length} transactions');

      setState(() {
        _transactions = transactionsExtended.map((tx) => TransactionLedgerRow(
              date: tx.date,
              timeAgo: tx.timeAgo,
              actionType: tx.actionType,
              actor: tx.actor,
              dealLead: tx.dealLead,
              fundingSource: tx.fundingSource,
              amount: tx.amount,
              isPositive: tx.isPositive,
              outcome: tx.outcome,
            )).toList();
        _loadingTransactions = false;
      });
    } catch (e, stack) {
      debugPrint('❌ Transaction load failed: $e');
      debugPrint('$stack');
      setState(() {
        _loadingTransactions = false;
      });
    }
  }

  void _handleTransactionTabChange(String tab) {
    setState(() {
      _selectedTransactionTab = tab;
    });
    _loadTransactions(tab);
  }

  int get totalValue => _inProgressValue + _awaitingApprovalValue;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1410),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1410),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadWalletData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1410),
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabs(context),

          WalletActionBar(
            onAdjustBalance: () {},
            onRecallTokens: () {},
            onSetWalletCap: () {},
            onFreeze: () {},
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: WalletBalanceCard(
                                balance: _walletBalance,
                                reservedTokens: _reservedTokens,
                                spentToday: _spentToday,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ActiveTasksCard(
                                totalTasks: _totalTasks,
                                totalValue: totalValue,
                                inProgressTasks: _inProgressTasks,
                                inProgressValue: _inProgressValue,
                                awaitingApprovalTasks: _awaitingApprovalTasks,
                                awaitingApprovalValue: _awaitingApprovalValue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SlaHealthCard(
                                recentSlaBreaches: _recentSlaBreaches,
                                tasksAtRisk: _tasksAtRisk,
                                xpEarned: _currentXp,
                                nextLv: _nextLevelXp,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildTransactionTable(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right column
                  Expanded(
                    flex: 1,
                    child: AgentMilestonesCard(
                      currentXp: _currentXp,
                      nextLevelXp: _nextLevelXp,
                      tokensEarned: _tokensEarned,
                      lastLnutDays: _lastLnutDays,
                      nextMilestoneAmount: _nextMilestoneAmount,
                      nextMilestoneDays: _nextMilestoneDays,
                      cardSetupComplete: _cardSetupComplete,
                      cardLastFour: _cardLastFour,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTable() {
    return Stack(
      children: [
        TransactionLedgerTable(
          transactions: _transactions,
          selectedTab: _selectedTransactionTab,
          onTabChanged: _handleTransactionTabChange,
          onViewFullLedger: () {},
        ),
        if (_loadingTransactions)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: const [
          _BrandMark(),
          SizedBox(width: 12),
          Text(
            'Realtor OS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          Text(
            'Last Activity:',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          SizedBox(width: 8),
          Text(
            '5 mins ago',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(width: 4),
          Icon(Icons.videocam_outlined, color: Colors.white54, size: 20),
          SizedBox(width: 24),
          Icon(Icons.access_time, color: Colors.white54, size: 20),
          SizedBox(width: 24),
          Icon(Icons.account_circle_outlined, color: Colors.white54, size: 20),
          SizedBox(width: 24),
          Icon(Icons.more_horiz, color: Colors.white54, size: 20),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 30, backgroundColor: Colors.grey),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _agentName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _agentRole,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Brokerage: $_brokerageName',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(width: 32),
              _buildTab('Wallet', true),
              const SizedBox(width: 32),
              _buildTab('Tasks', false),
              const SizedBox(width: 32),
              _buildTab('Settings', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 60,
          color: isActive ? const Color(0xFFB8764E) : Colors.transparent,
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFB8764E),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
