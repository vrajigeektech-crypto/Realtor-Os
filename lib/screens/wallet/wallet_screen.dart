import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/new_wallet_models.dart';
import '../../services/new_wallet_service.dart';
import '../../services/connection_test_service.dart';
import '../../layout/responsive_shell.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/ledger_table.dart';

/// ─────────────────────────────────────────────────
/// REALTOR OS — WALLET SCREEN
///
/// Fully responsive dark‑SaaS dashboard.
/// ◦ Desktop  → 3‑col top, 2‑col bottom + fixed sidebar
/// ◦ Tablet   → 2‑col grid + icon sidebar
/// ◦ Mobile   → stacked cards + Drawer
///
/// HARD RULE: Wallet math NEVER happens in Flutter.
/// ─────────────────────────────────────────────────
class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final NewWalletService _walletService = NewWalletService();

  bool _loading = true;
  String? _errorMessage;
  WalletDataBundle? _data;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 WalletScreen initState fired');
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      debugPrint('🔍 Running connection test…');
      final results = await ConnectionTestService.testConnection();
      ConnectionTestService.logResults(results);

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      setState(() {
        _loading = true;
        _errorMessage = null;
      });

      final data = await _walletService.loadAllWalletData(user.id);
      setState(() {
        _data = data;
        _loading = false;
      });

      debugPrint('✅ Wallet data loaded');
    } catch (e, stack) {
      debugPrint('❌ Wallet load failed: $e\n$stack');
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _executeAction(RecommendedIntervention intervention) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _walletService.executeAction(
        userId: user.id,
        actionType: intervention.actionKey,
        tokenCost: intervention.tokenCost,
      );

      _loadWalletData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor:
              response.success ? AppTheme.accent : Colors.red.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // build
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  @override
  Widget build(BuildContext context) {
    // Loading splash
    if (_loading) {
      return ResponsiveShell(
        activeIndex: 2,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.accent,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return ResponsiveShell(
        activeIndex: 2,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                      color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadWalletData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ResponsiveShell(
      activeIndex: 2,
      child: _WalletBody(
        data: _data,
        onExecuteAction: _executeAction,
        onRefresh: _loadWalletData,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// _WalletBody — layout switcher
// ══════════════════════════════════════════════════════
class _WalletBody extends StatelessWidget {
  const _WalletBody({
    required this.data,
    required this.onExecuteAction,
    required this.onRefresh,
  });

  final WalletDataBundle? data;
  final Future<void> Function(RecommendedIntervention) onExecuteAction;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.pagePadding(context);
    final size = ResponsiveHelper.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.accent,
      backgroundColor: AppTheme.bgCard,
      child: CustomScrollView(
        slivers: [
          // ── top page header ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  padding.left, padding.top, padding.right, 0),
              child: _PageHeader(
                onRefresh: onRefresh,
                automation: data?.automation,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── main grid ───────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(
                horizontal: padding.left, vertical: 0),
            sliver: SliverToBoxAdapter(
              child: size == ScreenSize.desktop
                  ? _DesktopGrid(
                      data: data,
                      onExecuteAction: onExecuteAction,
                    )
                  : size == ScreenSize.tablet
                      ? _TabletGrid(
                          data: data,
                          onExecuteAction: onExecuteAction,
                        )
                      : _MobileStack(
                          data: data,
                          onExecuteAction: onExecuteAction,
                        ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: padding.bottom + 24)),
        ],
      ),
    );
  }
}

// ── Page header ─────────────────────────────────────
class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onRefresh, this.automation});
  final Future<void> Function() onRefresh;
  final AutomationSummary? automation;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.of(context) == ScreenSize.mobile;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Wallet',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Execution balance & ledger',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (!isMobile && automation != null) ...[
          _AutomationSummaryHeader(automation: automation!),
          const SizedBox(width: 24),
        ],
        _RefreshButton(onRefresh: onRefresh),
      ],
    );
  }
}

class _AutomationSummaryHeader extends StatelessWidget {
  const _AutomationSummaryHeader({required this.automation});
  final AutomationSummary automation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: automation.vaStatus == 'online'
                    ? Colors.greenAccent
                    : Colors.orangeAccent,
                boxShadow: [
                  BoxShadow(
                    color: (automation.vaStatus == 'online'
                            ? Colors.greenAccent
                            : Colors.orangeAccent)
                        .withOpacity(0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'VA STATUS: ${automation.vaStatusDisplay.toUpperCase()}',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${automation.activeAssignmentsCount} Assignments | ${automation.runningTasksCount} Tasks Running',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _RefreshButton extends StatefulWidget {
  const _RefreshButton({required this.onRefresh});
  final Future<void> Function() onRefresh;
  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton>
    with SingleTickerProviderStateMixin {
  bool _busy = false;
  late AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    if (_busy) return;
    setState(() => _busy = true);
    _spin.repeat();
    await widget.onRefresh();
    _spin.stop();
    _spin.reset();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Refresh',
      onPressed: _tap,
      icon: RotationTransition(
        turns: _spin,
        child: const Icon(Icons.refresh_rounded,
            color: AppTheme.textSecondary, size: 20),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// DESKTOP GRID  (>= 1024 px)
// ══════════════════════════════════════════════════════
class _DesktopGrid extends StatelessWidget {
  const _DesktopGrid({required this.data, required this.onExecuteAction});
  final WalletDataBundle? data;
  final Future<void> Function(RecommendedIntervention) onExecuteAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── TOP ROW: 3 cols ──────────────────────────
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: _BalanceCard(data: data)),
              const SizedBox(width: 14),
              Expanded(flex: 4, child: _CompactLedgerCard(data: data)),
              const SizedBox(width: 14),
              Expanded(flex: 3, child: _ActiveCommitmentsCard(data: data)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── BOTTOM ROW: full ledger + right sidebar ──
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: _FullLedgerCard(data: data),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _RecommendedInterventionsCard(
                        data: data, onExecuteAction: onExecuteAction),
                    const SizedBox(height: 14),
                    _TrustLevelCard(data: data),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════
// TABLET GRID  (600 – 1023 px)
// ══════════════════════════════════════════════════════
class _TabletGrid extends StatelessWidget {
  const _TabletGrid({required this.data, required this.onExecuteAction});
  final WalletDataBundle? data;
  final Future<void> Function(RecommendedIntervention) onExecuteAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // row 1: balance + commitments
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _BalanceCard(data: data)),
              const SizedBox(width: 12),
              Expanded(child: _ActiveCommitmentsCard(data: data)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _CompactLedgerCard(data: data),
        const SizedBox(height: 12),
        _FullLedgerCard(data: data),
        const SizedBox(height: 12),
        // row: interventions + trust
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _RecommendedInterventionsCard(
                    data: data, onExecuteAction: onExecuteAction),
              ),
              const SizedBox(width: 12),
              Expanded(child: _TrustLevelCard(data: data)),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════
// MOBILE STACK  (< 600 px)
// ══════════════════════════════════════════════════════
class _MobileStack extends StatelessWidget {
  const _MobileStack({required this.data, required this.onExecuteAction});
  final WalletDataBundle? data;
  final Future<void> Function(RecommendedIntervention) onExecuteAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BalanceCard(data: data),
        const SizedBox(height: 12),
        _CompactLedgerCard(data: data),
        const SizedBox(height: 12),
        _ActiveCommitmentsCard(data: data),
        const SizedBox(height: 12),
        // On mobile, full ledger is horizontally scrollable
        _FullLedgerCard(data: data, scrollable: true),
        const SizedBox(height: 12),
        _RecommendedInterventionsCard(
            data: data, onExecuteAction: onExecuteAction),
        const SizedBox(height: 12),
        _TrustLevelCard(data: data),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════
// CARD WIDGETS
// ══════════════════════════════════════════════════════

// ── 1. Balance Card ───────────────────────────────────
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.data});
  final WalletDataBundle? data;

  @override
  Widget build(BuildContext context) {
    final balance = data?.balance ?? 0;
    final chartData = data?.history.reversed
        .take(14)
        .map((e) => e.runningBalance.toDouble())
        .toList();

    return DashboardCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // OST token circle
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.35),
                  blurRadius: 22,
                  spreadRadius: 3,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'OST',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Available Execution Balance',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${_fmt(balance)} OST',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Mini chart
          SizedBox(
            height: 42,
            child: CustomPaint(
              size: const Size(double.infinity, 42),
              painter: _MiniChartPainter(
                data: chartData ?? [],
                color: AppTheme.accent,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tokens are consumed only when actions execute',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── 2. Compact Ledger Card ───────────────────────────
class _CompactLedgerCard extends StatelessWidget {
  const _CompactLedgerCard({required this.data});
  final WalletDataBundle? data;

  @override
  Widget build(BuildContext context) {
    final txs = data?.transactions ?? [];
    final rows = txs.take(4).map((tx) => LedgerRow(
          date: '${tx.createdAt.month}/${tx.createdAt.day}',
          actionType: _actionLabel(tx.entryType),
          dealLead: tx.source.isNotEmpty ? tx.source : '—',
          fundingBadge: _FundingBadge(tx: tx),
          isBold: tx.entryType == 'spend',
        )).toList();

    return DashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Execution Ledger'),
          const SizedBox(height: 14),
          LedgerTable(
            rows: rows,
            compact: true,
            footerText: '+${txs.length > 4 ? txs.length - 4 : 0}'
                ' entries logged in last 3 days',
          ),
        ],
      ),
    );
  }
}

// ── 3. Active Commitments Card ───────────────────────
class _ActiveCommitmentsCard extends StatelessWidget {
  const _ActiveCommitmentsCard({required this.data});
  final WalletDataBundle? data;

  @override
  Widget build(BuildContext context) {
    final commits = data?.commitments ?? [];

    return DashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Active Commitments'),
          const SizedBox(height: 14),
          if (commits.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No active commitments',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            )
          else
            ...commits.map((c) => _CommitmentTile(
                  title: c.displayLabel,
                  subtitle: '${c.totalReservedAmount} tokens reserved',
                )),
        ],
      ),
    );
  }
}

class _CommitmentTile extends StatelessWidget {
  const _CommitmentTile({required this.title, required this.subtitle});
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: AppTheme.borderAccent, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppTheme.textMuted, size: 22),
        ],
      ),
    );
  }
}

// ── 4. Full Ledger Card ───────────────────────────────
class _FullLedgerCard extends StatelessWidget {
  const _FullLedgerCard({required this.data, this.scrollable = false});
  final WalletDataBundle? data;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final txs = data?.transactions ?? [];
    final rows = txs.take(10).map((tx) => LedgerRow(
          date: '${tx.createdAt.month}/${tx.createdAt.day}',
          actionType: _actionLabel(tx.entryType),
          dealLead: tx.source.isNotEmpty ? tx.source : '—',
          fundingSource: _fundingLabel(tx.entryType),
          outcome: _outcomeLabel(tx.entryType),
          isBold: tx.entryType == 'spend',
        )).toList();

    final table = LedgerTable(
      rows: rows,
      compact: false,
      footerText: '+${txs.length > 10 ? txs.length - 10 : 0}'
          ' entries logged in last 3 days',
    );

    return DashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Execution Ledger'),
          const SizedBox(height: 14),
          scrollable
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 680,
                    child: table,
                  ),
                )
              : table,
        ],
      ),
    );
  }
}

// ── 5. Recommended Interventions Card ────────────────
class _RecommendedInterventionsCard extends StatelessWidget {
  const _RecommendedInterventionsCard({
    required this.data,
    required this.onExecuteAction,
  });
  final WalletDataBundle? data;
  final Future<void> Function(RecommendedIntervention) onExecuteAction;

  @override
  Widget build(BuildContext context) {
    final items = data?.interventions ?? [];

    return DashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Recommended Interventions'),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No interventions recommended',
                  style:
                      TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            )
          else
            ...items.map((i) => _InterventionTile(
                  intervention: i,
                  onExecute: () => onExecuteAction(i),
                )),
        ],
      ),
    );
  }
}

class _InterventionTile extends StatelessWidget {
  const _InterventionTile({
    required this.intervention,
    required this.onExecute,
  });
  final RecommendedIntervention intervention;
  final VoidCallback onExecute;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171210),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppTheme.borderAccent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  intervention.description,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted, size: 18),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${intervention.interventionType}'
            ' (${intervention.tokenCost} tokens)',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: AccentButton(
              label: intervention.buttonText,
              onPressed: onExecute,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 6. Operational Trust Level Card ──────────────────
class _TrustLevelCard extends StatelessWidget {
  const _TrustLevelCard({required this.data});
  final WalletDataBundle? data;

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox.shrink();
    final trust = data!.trust;

    return DashboardCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Operational Trust Level ${trust.currentLevel}',
            trailing: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accent, width: 2),
              ),
              child: const Icon(Icons.shield_outlined,
                  color: AppTheme.accent, size: 14),
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                  begin: 0, end: trust.progressPercent / 100),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (ctx, val, _) => LinearProgressIndicator(
                value: val,
                minHeight: 7,
                backgroundColor: const Color(0xFF2A241E),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.accent),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Level ${trust.nextLevel} '
                '(${trust.progressPercent}%)',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
              const Text(
                'Healthy trust streak',
                style: TextStyle(
                    color: AppTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Funding badge chip ────────────────────────────────
class _FundingBadge extends StatelessWidget {
  const _FundingBadge({required this.tx});
  final WalletTransaction tx;

  @override
  Widget build(BuildContext context) {
    final isBroker =
        tx.entryType == 'earn' || tx.entryType == 'transfer';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A14),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppTheme.borderAccent, width: 0.5),
      ),
      child: Text(
        isBroker ? 'Broker' : 'You',
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 9,
          height: 1.2,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// Helpers
// ══════════════════════════════════════════════════════
String _fmt(int v) {
  return v.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

String _actionLabel(String t) {
  switch (t) {
    case 'earn':     return 'Tokens Earned';
    case 'spend':    return 'AI Call';
    case 'purchase': return 'Education Asset';
    case 'transfer': return 'Transfer';
    default:         return t;
  }
}

String _fundingLabel(String t) {
  switch (t) {
    case 'earn':
    case 'transfer': return 'Funded by Broker';
    default:         return 'Funded by You';
  }
}

String _outcomeLabel(String t) {
  switch (t) {
    case 'earn':     return 'Earned';
    case 'spend':    return 'Connected';
    case 'purchase': return 'No Answer';
    case 'transfer': return 'Transferred';
    default:         return '—';
  }
}

// ══════════════════════════════════════════════════════
// Mini Chart CustomPainter  (unchanged logic, cleaner)
// ══════════════════════════════════════════════════════
class _MiniChartPainter extends CustomPainter {
  _MiniChartPainter({required this.data, required this.color});
  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.35), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final maxV = data.reduce((a, b) => a > b ? a : b);
    final minV = data.reduce((a, b) => a < b ? a : b);
    final range = maxV - minV;
    if (range == 0) return;

    Offset toPoint(int i) {
      final x = i * size.width / (data.length - 1);
      final y = size.height -
          ((data[i] - minV) / range) * size.height * 0.82;
      return Offset(x, y);
    }

    final path     = Path();
    final fillPath = Path();
    for (int i = 0; i < data.length; i++) {
      final pt = toPoint(i);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
        fillPath.moveTo(pt.dx, size.height);
        fillPath.lineTo(pt.dx, pt.dy);
      } else {
        // smooth cubic
        final prev = toPoint(i - 1);
        final cpx = (prev.dx + pt.dx) / 2;
        path.cubicTo(cpx, prev.dy, cpx, pt.dy, pt.dx, pt.dy);
        fillPath.cubicTo(cpx, prev.dy, cpx, pt.dy, pt.dx, pt.dy);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniChartPainter old) =>
      old.data != data || old.color != color;
}
