import 'dart:math';
import 'package:flutter/material.dart';
import '../../screens/csv_import_screen.dart';
import '../../services/ai_lead_classifier_service.dart';
import '../../services/followupboss_contact_service.dart';
import '../../services/lead_classifier.dart';
class CRMConnectionDashboardApp extends StatelessWidget {
  final String? crmName;
  final String? provider;
  final int? totalContacts;
  final Map<String, dynamic>? metadata;

  const CRMConnectionDashboardApp({
    super.key,
    this.crmName,
    this.provider,
    this.totalContacts,
    this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lead Reactivation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Georgia',
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      home: CRMConnectionDashboardScreen(
        crmName: crmName,
        provider: provider,
        totalContacts: totalContacts,
        metadata: metadata,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  IMPORTING OVERLAY SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class ImportingOverlay extends StatefulWidget {
  final String? crmName;
  final int? totalContacts;
  final String? provider;

  const ImportingOverlay({
    super.key,
    this.crmName,
    this.totalContacts,
    this.provider,
  });

  @override
  State<ImportingOverlay> createState() => _ImportingOverlayState();
}

class _ImportingOverlayState extends State<ImportingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late AnimationController _spinCtrl;
  late Animation<double> _progressAnim;

  // 0 = pending, 1 = spinning, 2 = done
  int _step1 = 2;
  int _step2 = 1;
  int _step3 = 1;

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _progressAnim =
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);
    _progressCtrl.forward();

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 2000),
        () { if (mounted) setState(() => _step2 = 2); });

    Future.delayed(const Duration(milliseconds: 3600), () {
      if (!mounted) return;
      setState(() => _step3 = 2);
      // After a brief pause showing all steps done, navigate to imported data
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) => ImportedLeadsScreen(
            crmName: widget.crmName,
            totalContacts: widget.totalContacts,
            provider: widget.provider,
          ),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ));
      });
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _LeatherBgPainter()),
          // Top-right user chip
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: _buildUserChip(),
          ),
          Center(child: _buildCard()),
        ],
      ),
    );
  }

  Widget _buildUserChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.40),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF8B6A4A),
            child: const Icon(Icons.person, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          const Text('TK Mortgage Team',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: 480,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 36),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F08).withOpacity(0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5A3A1A).withOpacity(0.5), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.65), blurRadius: 48, spreadRadius: 6),
          BoxShadow(color: const Color(0xFFD4A030).withOpacity(0.05), blurRadius: 24, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Importing CRM Contacts...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 22),
          _buildProgressBar(),
          const SizedBox(height: 28),
          _buildStepRow(
            state: _step1,
            boldText: widget.totalContacts != null
                ? '${widget.totalContacts}'
                : '1,243',
            normalText: ' Contacts Imported',
          ),
          const SizedBox(height: 16),
          _buildStepRow(state: _step2, boldText: 'Analyzing Leads', normalText: ' with BPA...'),
          const SizedBox(height: 16),
          _buildStepRow(state: _step3, boldText: 'Scanning Database', normalText: ' for Buyers...'),
          const SizedBox(height: 28),
          Center(
            child: Text(
              'This only takes about 15–20 seconds.',
              style: TextStyle(color: Colors.white.withOpacity(0.50), fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (context, _) {
        final fill = 0.35 + (_progressAnim.value * 0.48);
        return ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF2A1A08),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: const Color(0xFF6B4A1A).withOpacity(0.35)),
            ),
            child: Stack(
              children: [
                // Gold fill
                FractionallySizedBox(
                  widthFactor: fill,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6B4A10),
                          Color(0xFFB88820),
                          Color(0xFFEFCC50),
                          Color(0xFFD4A830),
                          Color(0xFF8B6010),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A030).withOpacity(0.7),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                // Shimmer sweep
                AnimatedBuilder(
                  animation: _spinCtrl,
                  builder: (ctx, _) {
                    final x = _spinCtrl.value * 2 - 0.5;
                    return Positioned.fill(
                      child: IgnorePointer(
                        child: ShaderMask(
                          shaderCallback: (rect) => LinearGradient(
                            begin: Alignment(x - 0.4, 0),
                            end: Alignment(x + 0.4, 0),
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.28),
                              Colors.transparent,
                            ],
                          ).createShader(rect),
                          child: Container(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepRow({required int state, required String boldText, required String normalText}) {
    Widget icon;
    if (state == 2) {
      icon = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD4A030), width: 2),
        ),
        child: const Icon(Icons.check, color: Color(0xFFD4A030), size: 14),
      );
    } else {
      icon = AnimatedBuilder(
        animation: _spinCtrl,
        builder: (_, __) => Transform.rotate(
          angle: _spinCtrl.value * 2 * pi,
          child: SizedBox(width: 24, height: 24, child: CustomPaint(painter: _ArcSpinnerPainter())),
        ),
      );
    }

    return Row(
      children: [
        icon,
        const SizedBox(width: 14),
        Expanded(
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: boldText,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              TextSpan(
                  text: normalText,
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 15)),
            ]),
          ),
        ),
      ],
    );
  }
}

// Gold arc spinner
class _ArcSpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3);
    // Track
    canvas.drawArc(
      r, 0, 2 * pi, false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = const Color(0xFF5A3A1A).withOpacity(0.5),
    );
    // Arc with gradient
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [Colors.transparent, const Color(0xFFD4A030)],
        startAngle: 0,
        endAngle: 1.6 * pi,
      ).createShader(r);
    canvas.drawArc(r, -pi / 2, 1.6 * pi, false, paint);
  }

  @override
  bool shouldRepaint(_ArcSpinnerPainter _) => false;
}

// Dark leather/burnt wood background
class _LeatherBgPainter extends CustomPainter {
  final _rng = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Base radial gradient
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.1, -0.2),
          radius: 1.3,
          colors: const [
            Color(0xFF4A2010),
            Color(0xFF2A1008),
            Color(0xFF120602),
          ],
        ).createShader(rect),
    );

    // Texture dots
    final dot = Paint()..color = const Color(0xFF3A1A08).withOpacity(0.35);
    for (int i = 0; i < 400; i++) {
      canvas.drawCircle(
        Offset(_rng.nextDouble() * size.width, _rng.nextDouble() * size.height),
        _rng.nextDouble() * 2.8 + 0.4,
        dot,
      );
    }

    // Vignette
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [Colors.transparent, Colors.black.withOpacity(0.70)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_LeatherBgPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN LEAD REACTIVATION SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class CRMConnectionDashboardScreen extends StatefulWidget {
  final String? crmName;
  final String? provider;
  final int? totalContacts;
  final Map<String, dynamic>? metadata;

  const CRMConnectionDashboardScreen({
    super.key,
    this.crmName,
    this.provider,
    this.totalContacts,
    this.metadata,
  });

  @override
  State<CRMConnectionDashboardScreen> createState() => _CRMConnectionDashboardScreenState();
}

class _CRMConnectionDashboardScreenState extends State<CRMConnectionDashboardScreen> {
  double campaignLength = 1;
  double warmTransfers = 15;

  // Live classified bucket counts
  bool _statsLoading = true;
  int _totalLive = 0;
  int _hotCount = 0;
  int _warmCount = 0;
  int _coldCount = 0;
  int _junkCount = 0;

  int get estimatedMinutes => campaignLength.round() * 100;
  int get estimatedWarmTransfers => warmTransfers.round();
  int get estimatedAppointments => 7;
  double get minuteTokens => estimatedMinutes * 0.3;
  double get warmTransferTokens => estimatedWarmTransfers * 10;
  double get appointmentTokens => estimatedAppointments * 4;
  double get totalCost => minuteTokens + warmTransferTokens + appointmentTokens;
  double get balanceAfter => 754 - totalCost;

  @override
  void initState() {
    super.initState();
    _loadLiveStats();
  }

  Future<void> _loadLiveStats() async {
    try {
      List<Map<String, dynamic>> people = [];

      if (widget.provider == 'followupboss') {
        final service = FollowUpBossContactService();
        final result = await service.getPeople(limit: 200);
        people = (result['people'] as List? ?? []).cast<Map<String, dynamic>>();
      }

      // Try AI classification; rule-based fires automatically on failure.
      await AiLeadClassifierService.classifyAll(people);

      int hot = 0, warm = 0, cold = 0, junk = 0;
      for (final c in people) {
        switch ((c['_classification'] as LeadClassification?)?.bucket) {
          case LeadBucket.hot:
            hot++;
          case LeadBucket.warm:
            warm++;
          case LeadBucket.cold:
            cold++;
          default:
            junk++;
        }
      }

      if (mounted) {
        setState(() {
          _totalLive = people.length;
          _hotCount = hot;
          _warmCount = warm;
          _coldCount = cold;
          _junkCount = junk;
          _statsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  void _onStartCampaign() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => ImportingOverlay(
        crmName: widget.crmName,
        totalContacts: widget.totalContacts,
        provider: widget.provider,
      ),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  void _onImportCsv() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CsvImportScreen(
        provider: widget.provider ?? 'followupboss',
        crmName: widget.crmName ?? 'CRM',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(builder: (context, constraints) {
            return constraints.maxWidth > 700
                ? _buildWideLayout()
                : _buildNarrowLayout();
          }),
        ),
      ),
    );
  }

  Widget _buildWideLayout() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildHeader(),
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: Column(children: [
                _buildTopCards(),
                const SizedBox(height: 16),
                _buildPurchaseSection(),
              ])),
          const SizedBox(width: 16),
          SizedBox(width: 280, child: _buildTotalsPanel()),
        ],
      ),
    ],
  );

  Widget _buildNarrowLayout() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildHeader(),
      const SizedBox(height: 16),
      _buildTopCards(),
      const SizedBox(height: 16),
      _buildPurchaseSection(),
      const SizedBox(height: 16),
      _buildTotalsPanel(),
    ],
  );

  Widget _buildHeader() {
    final name = widget.crmName ?? 'CRM';
    final contacts = widget.totalContacts;
    final canPop = Navigator.of(context).canPop();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (canPop)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            Expanded(
              child: Text('Pay for Instant Lead Reactivation',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1a3a2a),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 13),
                  const SizedBox(width: 5),
                  Text(
                    name,
                    style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: EdgeInsets.only(left: canPop ? 32 : 0),
          child: Text(
            _statsLoading
                ? 'Loading contacts…'
                : _totalLive > 0
                    ? '$_totalLive contacts · activate AI calling to reactivate leads.'
                    : contacts != null
                        ? '$contacts contacts imported · activate AI calling to reactivate leads.'
                        : 'Get connected & ready-to-transfer leads by activating AI calling campaigns.',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildTopCards() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF252525),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: Column(children: [
      // AI badge row
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.35)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.auto_awesome, color: Colors.green, size: 11),
              const SizedBox(width: 4),
              Text(
                _statsLoading ? 'AI Classifying…' : 'AI Classified',
                style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statsLoading
                  ? 'Analyzing leads with GPT-4o-mini…'
                  : 'GPT-4o-mini · ${_totalLive > 0 ? _totalLive : widget.totalContacts ?? 0} leads analyzed',
              style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 10.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(children: [
        // 🔥 Hot
        Expanded(child: _statCard(
          const Color(0xFF2D1A10), const Color(0xFF5A2A10),
          Icons.local_fire_department, const Color(0xFFFF6B35),
          '🔥 Hot\nLeads',
          _statsLoading
              ? _loadingWidget(const Color(0xFFFF6B35))
              : _countWidget('$_hotCount', 'call first', const Color(0xFFFF6B35)),
        )),
        const SizedBox(width: 10),
        // 🌤 Warm
        Expanded(child: _statCard(
          const Color(0xFF3B3020), const Color(0xFF6B5420),
          Icons.wb_sunny_outlined, const Color(0xFFD4A840),
          '🌤 Warm\nLeads',
          _statsLoading
              ? _loadingWidget(const Color(0xFFD4A840))
              : _countWidget('$_warmCount', 'nurture', const Color(0xFFD4A840)),
        )),
        const SizedBox(width: 10),
        // ❄️ Cold
        Expanded(child: _statCard(
          const Color(0xFF1A2030), const Color(0xFF2A3A5A),
          Icons.ac_unit, const Color(0xFF7BB8D4),
          '❄️ Cold\nLeads',
          _statsLoading
              ? _loadingWidget(const Color(0xFF7BB8D4))
              : _countWidget('$_coldCount', 'reactivate', const Color(0xFF7BB8D4)),
        )),
        const SizedBox(width: 10),
        // 🚫 Junk
        Expanded(child: _statCard(
          const Color(0xFF2A2A2A), const Color(0xFF444444),
          Icons.do_not_disturb_alt, const Color(0xFF7A7A7A),
          '🚫 Junk',
          _statsLoading
              ? _loadingWidget(const Color(0xFF7A7A7A))
              : _countWidget('$_junkCount', 'skip', const Color(0xFF7A7A7A)),
        )),
      ]),
      const SizedBox(height: 14),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(text: TextSpan(children: [
            TextSpan(
              text: _totalLive > 0 ? '$_totalLive contacts synced · '
                  : widget.totalContacts != null ? '${widget.totalContacts} contacts synced · ' : '',
              style: const TextStyle(color: Color(0xFFD4A840), fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const TextSpan(text: '1 purchase = 1 hour of AI dials ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            const TextSpan(text: 'at estimated transfer rate', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13)),
          ])),
          const SizedBox(height: 2),
          Text('Unused minutes can be left in account for future campaigns',
              style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11.5)),
        ]),
      ),
    ]),
  );

  Widget _loadingWidget(Color color) => SizedBox(
    height: 44,
    child: Center(
      child: SizedBox(
        width: 18, height: 18,
        child: CircularProgressIndicator(
          color: color, strokeWidth: 1.5,
        ),
      ),
    ),
  );

  Widget _countWidget(String count, String sub, Color color) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(count,
          style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(sub,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 10)),
    ],
  );

  Widget _statCard(Color bg, Color border, IconData icon, Color iconColor, String title, Widget value) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border.withOpacity(0.6)),
        ),
        child: Column(children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4)),
          const SizedBox(height: 10),
          value,
        ]),
      );

  Widget _buildPurchaseSection() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF252525),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Purchase Calling Tokens',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _slider('Campaign Length', '${campaignLength.round()} hours', campaignLength, 1, 8, 7, (v) => setState(() => campaignLength = v))),
        const SizedBox(width: 24),
        Expanded(child: _slider('Warm Transfers Desired', '${warmTransfers.round()} trokens', warmTransfers, 5, 50, 45, (v) => setState(() => warmTransfers = v))),
      ]),
      const SizedBox(height: 24),
      const Divider(color: Color(0xFF3A3A3A)),
      const SizedBox(height: 14),
      const Text('Totals', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      _totalRow('Estimated Minutes:', '$estimatedMinutes minutes @ .3 tokens', '${minuteTokens.toStringAsFixed(0)} Tokens'),
      const SizedBox(height: 8),
      _totalRow('Estimated Warm Transfers', '$estimatedWarmTransfers transfers @ 10 tokens', '${warmTransferTokens.toStringAsFixed(0)} Tokens'),
      const SizedBox(height: 8),
      _totalRow('Estimated Appointments:', '$estimatedAppointments appointments @ 4 tokens', '${appointmentTokens.toStringAsFixed(0)} Tokens'),
      const SizedBox(height: 16),
      Center(child: RichText(text: TextSpan(children: [
        const TextSpan(text: 'Balance after purchase: ', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13)),
        TextSpan(text: '${balanceAfter.toStringAsFixed(0)} Tokens', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ]))),
      const SizedBox(height: 10),
      Text('Estimated results. Actual transfer/appointment count may vary.',
          style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10.5)),
    ]),
  );

  Widget _slider(String label, String val, double value, double min, double max, int div, ValueChanged<double> cb) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13)),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            activeTrackColor: const Color(0xFFD4A840),
            inactiveTrackColor: const Color(0xFF444444),
            thumbColor: const Color(0xFFD4A840),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayColor: const Color(0xFFD4A840).withOpacity(0.2),
          ),
          child: Slider(value: value, min: min, max: max, divisions: div, onChanged: cb),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${min.toInt()}', style: const TextStyle(color: Color(0xFF888888), fontSize: 11)),
          Text('${max.toInt()}', style: const TextStyle(color: Color(0xFF888888), fontSize: 11)),
        ]),
      ]);

  Widget _totalRow(String label, String detail, String amount) => Row(children: [
    SizedBox(width: 160, child: Text(label, style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13))),
    Expanded(child: Text(detail, style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13))),
    Text(amount, style: const TextStyle(color: Color(0xFFD4A840), fontSize: 13, fontWeight: FontWeight.w600)),
  ]);

  Widget _buildTotalsPanel() => Column(children: [
    _panelBox([
      const Text('Totals', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      _panelItem('Estimated Minutes:', '$estimatedMinutes minutes @ .3 tokens', '${minuteTokens.toStringAsFixed(0)} Tocens'),
      const SizedBox(height: 14),
      _panelItem('Estimated Warm Transfers:', '$estimatedWarmTransfers transfers @ 10 tokens', '${warmTransferTokens.toStringAsFixed(0)} Tokens'),
      const SizedBox(height: 14),
      _panelItem('Estimated Appointments:', '$estimatedAppointments appointments @ 4 tokens', '${appointmentTokens.toStringAsFixed(0)} Tokens'),
    ]),
    const SizedBox(height: 12),
    _panelBox([
      const Text('Total Cost', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      Center(child: RichText(text: TextSpan(children: [
        TextSpan(text: '${totalCost.toStringAsFixed(0)} ', style: const TextStyle(color: Color(0xFFD4A840), fontSize: 42, fontWeight: FontWeight.bold)),
        const TextSpan(text: 'Tokens', style: TextStyle(color: Color(0xFFD4A840), fontSize: 20, fontWeight: FontWeight.w500)),
      ]))),
      const SizedBox(height: 8),
      Center(child: Text('Balance after purchase: ${balanceAfter.toStringAsFixed(0)} Tokens',
          style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12))),
      const SizedBox(height: 18),
      SizedBox(
        width: double.infinity,
          child: ElevatedButton(
          onPressed: _onStartCampaign,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB8860B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 4,
          ),
          child: const Text('START CALLING CAMPAIGN',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _onImportCsv,
          icon: const Icon(Icons.upload_file_outlined, size: 15),
          label: const Text('Import Contacts from CSV',
              style: TextStyle(fontSize: 13)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFB8860B),
            side: const BorderSide(color: Color(0xFFB8860B), width: 1),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    ]),
  ]);

  Widget _panelBox(List<Widget> children) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF252525),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  Widget _panelItem(String label, String detail, String amount) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(detail, style: const TextStyle(color: Color(0xFF999999), fontSize: 12))),
        Text(amount, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
      ]),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  IMPORTED LEADS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class ImportedLeadsScreen extends StatefulWidget {
  final String? crmName;
  final int? totalContacts;
  final String? provider;

  const ImportedLeadsScreen({
    super.key,
    this.crmName,
    this.totalContacts,
    this.provider,
  });

  @override
  State<ImportedLeadsScreen> createState() => _ImportedLeadsScreenState();
}

class _ImportedLeadsScreenState extends State<ImportedLeadsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _contacts = [];

  // Derived from per-contact classifications — never set directly.
  int get _hotLeads => _contacts.where(_bucketOf(LeadBucket.hot)).length;
  int get _warmLeads => _contacts.where(_bucketOf(LeadBucket.warm)).length;
  int get _coldLeads => _contacts.where(_bucketOf(LeadBucket.cold)).length;
  int get _junkLeads => _contacts.where(_bucketOf(LeadBucket.junk)).length;

  static bool Function(Map<String, dynamic>) _bucketOf(LeadBucket b) =>
      (c) => (c['_classification'] as LeadClassification?)?.bucket == b;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    try {
      List<Map<String, dynamic>> people;

      if (widget.provider == 'followupboss') {
        final service = FollowUpBossContactService();
        final result = await service.getPeople(limit: 100);
        people = (result['people'] as List? ?? []).cast<Map<String, dynamic>>();
      } else {
        // Non-FUB provider: no live contacts yet — show empty state.
        await Future.delayed(const Duration(milliseconds: 300));
        people = [];
      }

      // AI classify (falls back to rule-based automatically).
      await AiLeadClassifierService.classifyAll(people);
      // Sort: hot → warm → cold → junk
      people.sort((a, b) {
        final ai =
            (a['_classification'] as LeadClassification?)?.bucket.index ?? 3;
        final bi =
            (b['_classification'] as LeadClassification?)?.bucket.index ?? 3;
        return ai.compareTo(bi);
      });

      if (mounted) {
        setState(() {
          _contacts = people;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSuccessBanner(),
            _buildStatsRow(),
            const Divider(color: Color(0xFF2E2E2E), height: 1),
            Expanded(child: _buildContactsArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF1C1C1C),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 4),
          const Text('Imported Contacts',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (widget.crmName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1a3a2a),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 12),
                  const SizedBox(width: 4),
                  Text(widget.crmName!,
                      style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    final total = widget.totalContacts ?? _contacts.length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2B1A), Color(0xFF1A2D10)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.15),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: const Icon(Icons.check, color: Colors.green, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total > 0 ? '$total Contacts Successfully Imported' : 'Contacts Successfully Imported',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'AI analysis complete · leads categorized & ready for campaign',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('BPA Score', style: TextStyle(color: Color(0xFFD4A840), fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              const Text('Ready', style: TextStyle(color: Color(0xFFD4A840), fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _statChip('🔥 Hot', _hotLeads, const Color(0xFF2D1A10), const Color(0xFFFF6B35), Icons.local_fire_department),
          const SizedBox(width: 8),
          _statChip('🌤 Warm', _warmLeads, const Color(0xFF3B3020), const Color(0xFFD4A840), Icons.wb_sunny_outlined),
          const SizedBox(width: 8),
          _statChip('❄️ Cold', _coldLeads, const Color(0xFF1A2030), const Color(0xFF7BB8D4), Icons.ac_unit),
          const SizedBox(width: 8),
          _statChip('🚫 Junk', _junkLeads, const Color(0xFF2A2A2A), const Color(0xFF888888), Icons.do_not_disturb_alt),
        ],
      ),
    );
  }

  Widget _statChip(String label, int count, Color bg, Color accent, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(height: 4),
            Text('$count',
                style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsArea() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFD4A840), strokeWidth: 2),
            SizedBox(height: 14),
            Text('Fetching contacts...', style: TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade300, size: 40),
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, color: Colors.white24, size: 48),
            const SizedBox(height: 12),
            const Text('No contacts to display',
                style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _contacts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _buildContactTile(_contacts[i], i),
    );
  }

  Widget _buildContactTile(Map<String, dynamic> contact, int index) {
    final firstName = contact['firstName'] as String? ?? '';
    final lastName = contact['lastName'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim().isEmpty
        ? 'Unknown Contact'
        : '$firstName $lastName'.trim();

    final emails = (contact['emails'] as List? ?? []);
    final email = emails.isNotEmpty ? (emails.first['value'] as String? ?? '') : '';

    final phones = (contact['phones'] as List? ?? []);
    final phone = phones.isNotEmpty ? (phones.first['value'] as String? ?? '') : '';

    final stage = contact['stage'] as String? ?? '';
    final tags = ((contact['tags'] as List?) ?? []).cast<String>();

    // Read the per-contact classification from the classifier.
    final cls = contact['_classification'] as LeadClassification?;
    final bucket = cls?.bucket ?? LeadBucket.cold;
    final confidence = cls?.confidence ?? 30;
    final signals = cls?.signals ?? [];

    final (accentColor, categoryIcon) = _bucketStyle(bucket);
    final categoryLabel = '${bucket.emoji} ${bucket.label}';
    final intent = cls?.intent ?? '';
    final urgency = cls?.urgency ?? '';
    final budget = cls?.budget ?? 'unknown';
    final category = cls?.category ?? '';
    final aiClassified = cls?.aiClassified ?? false;

    final initials = [
      firstName.isNotEmpty ? firstName[0] : '',
      lastName.isNotEmpty ? lastName[0] : '',
    ].join().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + confidence ring
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accentColor.withOpacity(0.15),
                child: Text(
                  initials.isEmpty ? '?' : initials,
                  style: TextStyle(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$confidence%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row + bucket badge
                Row(
                  children: [
                    Expanded(
                      child: Text(fullName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accentColor.withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(categoryIcon, color: accentColor, size: 10),
                          const SizedBox(width: 3),
                          Text(categoryLabel,
                              style: TextStyle(
                                  color: accentColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                // Confidence bar
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: confidence / 100,
                    minHeight: 2,
                    backgroundColor: Colors.white12,
                    color: accentColor,
                  ),
                ),
                // AI output row: intent · urgency · budget
                if (intent.isNotEmpty && intent != 'unknown') ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (aiClassified)
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.auto_awesome, color: Colors.green, size: 8),
                            SizedBox(width: 2),
                            Text('AI', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      _aiPill(intent, accentColor),
                      const SizedBox(width: 4),
                      _urgencyDot(urgency),
                      const SizedBox(width: 4),
                      if (budget != 'unknown' && budget.isNotEmpty)
                        _aiPill('Budget: $budget', const Color(0xFF8AB8A0)),
                      if (category.isNotEmpty && category != 'unknown') ...[
                        const SizedBox(width: 4),
                        _aiPill(category, Colors.white38),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 5),
                // Contact info row
                Row(
                  children: [
                    if (email.isNotEmpty) ...[
                      Icon(Icons.email_outlined, color: Colors.white38, size: 12),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(email,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (phone.isNotEmpty) ...[
                      Icon(Icons.phone_outlined, color: Colors.white38, size: 12),
                      const SizedBox(width: 3),
                      Text(phone,
                          style:
                              const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ],
                ),
                // Stage / tags + classifier signals
                if (stage.isNotEmpty || tags.isNotEmpty || signals.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (stage.isNotEmpty)
                        _tag(stage, const Color(0xFF3A3A3A), Colors.white60),
                      ...tags.take(2).map((t) => _tag(
                            t,
                            accentColor.withOpacity(0.10),
                            accentColor.withOpacity(0.75),
                          )),
                      ...signals.take(1).map((s) => _signalChip(s, accentColor)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static (Color, IconData) _bucketStyle(LeadBucket bucket) => switch (bucket) {
        LeadBucket.hot => (const Color(0xFFFF6B35), Icons.local_fire_department),
        LeadBucket.warm => (const Color(0xFFD4A840), Icons.wb_sunny_outlined),
        LeadBucket.cold => (const Color(0xFF7BB8D4), Icons.ac_unit),
        LeadBucket.junk => (const Color(0xFF888888), Icons.do_not_disturb_alt),
      };

  Widget _aiPill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Text(label,
        style: TextStyle(
            color: color.withOpacity(0.85), fontSize: 9, fontWeight: FontWeight.w500)),
  );

  Widget _urgencyDot(String urgency) {
    final (color, label) = switch (urgency) {
      'high' => (const Color(0xFFFF6B35), '● High'),
      'medium' => (const Color(0xFFD4A840), '● Med'),
      _ => (const Color(0xFF7BB8D4), '● Low'),
    };
    return Text(label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600));
  }

  Widget _signalChip(String label, Color accent) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: accent.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: accent.withOpacity(0.6), size: 8),
            const SizedBox(width: 3),
            Text(label,
                style: TextStyle(
                    color: accent.withOpacity(0.7),
                    fontSize: 9,
                    fontStyle: FontStyle.italic)),
          ],
        ),
      );

  Widget _tag(String label, Color bg, Color textColor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: TextStyle(color: textColor, fontSize: 10)),
  );
}