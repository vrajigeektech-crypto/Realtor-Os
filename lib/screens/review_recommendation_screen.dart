import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../layout/main_layout.dart';
import '../services/recommendation_service.dart';
import '../models/recommendation_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/balance_service.dart';

class ReviewRecommendationScreen extends StatefulWidget {
  final Map<String, dynamic> recommendation;

  const ReviewRecommendationScreen({
    super.key,
    required this.recommendation,
  });

  @override
  State<ReviewRecommendationScreen> createState() => _ReviewRecommendationScreenState();
}

class _ReviewRecommendationScreenState extends State<ReviewRecommendationScreen> {
  final RecommendationService _recommendationService = RecommendationService();
  final BalanceService _balanceService = BalanceService();

  bool _isLaunching = false;
  double _currentBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = _balanceService.currentBalance;
    setState(() {
      _currentBalance = balance;
    });
  }

  Future<void> _launchWorkflow() async {
    if (_isLaunching) return;

    setState(() {
      _isLaunching = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final tokenCost = widget.recommendation['token_cost'] ?? 5;

      if (_currentBalance < tokenCost) {
        _showInsufficientBalanceDialog(tokenCost);
        return;
      }

      final queueItem = await _recommendationService.purchasePromotion(
        userId: userId,
        promotionId: widget.recommendation['id'].toString(),
        promotionTitle: widget.recommendation['title'] ?? 'AI Workflow',
        tokenCost: tokenCost,
      );

      if (queueItem == null) throw Exception('Failed to launch workflow');

      _showSuccessDialog();
      await _loadBalance();
    } catch (e) {
      _showErrorDialog('Failed to launch workflow: ${e.toString()}');
    } finally {
      setState(() {
        _isLaunching = false;
      });
    }
  }

  void _showInsufficientBalanceDialog(int requiredTokens) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Insufficient Balance', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You need $requiredTokens tokens to launch this workflow.',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Text('Current balance: ${_currentBalance.toInt()} tokens',
                style: const TextStyle(color: Color(0xFFb1997d))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainLayout(activeIndex: 2, child: SizedBox()),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFb1997d), foregroundColor: Colors.black),
            child: const Text('Buy Tokens'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Workflow Launched!', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text('Your workflow has been added to the automation queue.',
                style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text('It will be processed automatically.',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFb1997d), foregroundColor: Colors.black),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFFb1997d))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokenCost = widget.recommendation['token_cost'] ?? 5;
    final platform = widget.recommendation['platform'] ?? 'Instagram · TikTok · LinkedIn';
    final title = widget.recommendation['title'] ?? 'Weekly Market Insight';

    return MainLayout(
      activeIndex: 11,
      title: 'Review Recommendation',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page subtitle
            Text(
              'Review Recommendation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Automate your presence with personalized, agent-branded social posts.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // 3-column layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT: Phone mockup
                      SizedBox(
                        width: 300,
                        child: _buildPhoneMockup(),
                      ),
                      const SizedBox(width: 24),

                      // MIDDLE: What This Is, Why Showing, What You Get
                      Expanded(
                        child: _buildMiddleColumn(title),
                      ),
                      const SizedBox(width: 24),

                      // RIGHT: Execution details + Launch
                      SizedBox(
                        width: 320,
                        child: _buildRightColumn(tokenCost, platform),
                      ),
                    ],
                  );
                } else {
                  // Stacked on narrow screens
                  return Column(
                    children: [
                      _buildPhoneMockup(),
                      const SizedBox(height: 24),
                      _buildMiddleColumn(title),
                      const SizedBox(height: 24),
                      _buildRightColumn(tokenCost, platform),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── LEFT COLUMN: Phone Mockup ───────────────────────────────────────────────

  Widget _buildPhoneMockup() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Phone frame
          Container(
            width: 240,
            height: 480,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.grey.shade800, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                // Background gradient matching the image
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2A2A2A), // Dark gray at top
                        Color(0xFF1A1A1A), // Medium dark
                        Color(0xFF0A0A0A), // Very dark
                        Color(0xFF000000), // Black at bottom
                      ],
                    ),
                  ),
                ),

                // Main image of the woman (placeholder for actual image)
                Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                    ),
                    child: Stack(
                      children: [
                        // Placeholder for woman's image
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.grey.shade700,
                                Colors.grey.shade900,
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Network image as background
                              Image.network(
                                'https://via.placeholder.com/400x300/b1997d/ffffff?text=Jessica',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Main image error: $error');
                                  return Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFb1997d).withOpacity(0.4),
                                          Color(0xFF8B7355).withOpacity(0.3),
                                          Color(0xFF5A4A3A).withOpacity(0.2),
                                        ],
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 80,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Overlay gradient for better text visibility
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.3),
                                      Colors.black.withOpacity(0.6),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // AI-Cloned badge at top
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFb1997d), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.favorite, color: Color(0xFFb1997d), size: 12),
                          SizedBox(width: 4),
                          Text(
                            'AI-Cloned • Your Voice',
                            style: TextStyle(
                              color: Color(0xFFb1997d),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // READY FOR APPROVAL badge
                Positioned(
                  top: 44,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFb1997d),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'READY FOR APPROVAL',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),

                // Waveform visualization over the image
                Positioned(
                  top: 220,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(25, (i) {
                      final heights = [8, 12, 16, 20, 24, 20, 16, 12, 8, 6, 10, 14, 18, 14, 10, 6, 8, 12, 16, 12, 8, 6, 10, 8, 6];
                      final height = heights[i % heights.length];
                      return Container(
                        width: 3,
                        height: height.toDouble(),
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),

                // Profile section with small avatar and name
                Positioned(
                  top: 260,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      // Small circular profile picture
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFFb1997d),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://via.placeholder.com/100x100/b1997d/ffffff?text=JW',
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Avatar image error: $error');
                              return Container(
                                width: 36,
                                height: 36,
                                color: Color(0xFFb1997d),
                                child: const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name and title
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jessica Williams',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Your Local Realtor',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bottom content
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      const Text(
                        'Weekly Market Insight',
                        style: TextStyle(
                          color: Color(0xFFb1997d),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '— Posted as You',
                        style: TextStyle(
                          color: Color(0xFFb1997d),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Short, professional video designed to keep you visible, credible, and relevant without manual effort.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Status bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('9:41',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        Row(
                          children: const [
                            Icon(Icons.signal_cellular_alt, color: Colors.white, size: 11),
                            SizedBox(width: 3),
                            Icon(Icons.wifi, color: Colors.white, size: 11),
                            SizedBox(width: 3),
                            Icon(Icons.battery_full, color: Colors.white, size: 11),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── MIDDLE COLUMN ───────────────────────────────────────────────────────────

  Widget _buildMiddleColumn(String title) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // What This Is
          _buildSectionTitle('What This Is'),
          const SizedBox(height: 12),
          Text(
            '$title — Posted as You',
            style: const TextStyle(
              color: const Color(0xFFb1997d),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Short, professional video designed to keep you visible, credible, and relevant without manual effort. It\'s designed to maintain presence, educate your audience, and reinforce trust—without you recording, editing, or posting manually.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.55),
          ),

          const SizedBox(height: 28),
          _buildDivider(),
          const SizedBox(height: 24),

          // Why This Is Showing
          _buildSectionTitle('Why This Is Showing:'),
          const SizedBox(height: 14),
          _buildBulletPoint('You have ', boldPart: 'active buyers', tail: ' and listings'),
          const SizedBox(height: 10),
          _buildBulletPoint('No recent ', boldPart: 'educational or market', tail: ' content posted'),
          const SizedBox(height: 10),
          _buildBulletPoint('Maintaining visibility supports deal momentum'),

          const SizedBox(height: 28),
          _buildDivider(),
          const SizedBox(height: 24),

          // What You Get
          _buildSectionTitle('What You Get:'),
          const SizedBox(height: 14),
          _buildCheckItem('Custom script written for your audience'),
          const SizedBox(height: 10),
          _buildCheckItem('AI voice clone applied'),
          const SizedBox(height: 10),
          _buildCheckItem('Branded visuals (name, city, positioning)'),
          const SizedBox(height: 10),
          _buildCheckItem('Platform-specific formatting (IG / TikTok / LinkedIn)'),
          const SizedBox(height: 10),
          _buildCheckItem('Added to your posting queue'),
          const SizedBox(height: 16),
          Text(
            '+ Nothing posts without your confirmation.',
            style: TextStyle(
              color: Color(0xFFb1997d),
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: const Color(0xFF2A2A2A));
  }

  Widget _buildBulletPoint(String text, {String? boldPart, String? tail}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 5, right: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFb1997d),
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: boldPart != null
              ? RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              children: [
                TextSpan(text: text),
                TextSpan(
                    text: boldPart,
                    style: const TextStyle(
                        color: Colors.white70)),
                if (tail != null) TextSpan(text: tail),
              ],
            ),
          )
              : Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check, color: Color(0xFFb1997d), size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ),
      ],
    );
  }

  // ─── RIGHT COLUMN ────────────────────────────────────────────────────────────

  Widget _buildRightColumn(int tokenCost, String platform) {
    return Column(
      children: [
        // Execution Details card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Execution Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Execution Type:', 'AI-Generated · Agent-Branded'),
              _buildDetailRowDivider(),
              _buildDetailRow('Posting:', 'Manual approval required'),
              _buildDetailRowDivider(),
              _buildDetailRow('Turnaround:', 'Within 24 hours'),
              _buildDetailRowDivider(),
              _buildDetailRow('Platforms:', platform),
              const SizedBox(height: 12),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.white38),
                  children: [
                    TextSpan(text: 'Reuse: ',style: TextStyle(color: Colors.white70)),
                    TextSpan(
                      text: 'Can also be sent directly to clients',
                      style: TextStyle(color: const Color(0xFFb1997d)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Token Cost card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Token Cost: ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),Text(
                    '$tokenCost OST',
                    style: const TextStyle(
                      color: const Color(0xFFb1997d),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Rewards',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildRewardRow(Icons.diamond, '+2 XP'),
              const SizedBox(height: 8),
              _buildRewardRow(Icons.diamond, 'Counts toward weekly consistency'),
              const SizedBox(height: 8),
              _buildRewardRow(Icons.diamond, 'Improves Operational Trust Level'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Launch button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLaunching ? null : _launchWorkflow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF967655),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isLaunching
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 10),
                Text('Launching...', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            )
                : const Text(
              'Launch Workflow',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // AI disclaimer text
        const Text(
          'AI will generate the content and place it in your approval queue. No posting happens without your confirmation.',
          style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // Bottom action links
        _buildActionLink(Icons.play_circle_outline, 'View Sample Output'),
        const SizedBox(height: 12),
        _buildActionLink(Icons.swap_horiz, 'Change Platform Selection'),
        const SizedBox(height: 12),
        _buildActionLink(Icons.skip_next, 'Skip for Now', muted: true),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowDivider() {
    return Container(height: 1, color: const Color(0xFF1E1E1E));
  }

  Widget _buildRewardRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFb1997d), size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildActionLink(IconData icon, String label, {bool muted = false}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Row(
        children: [
          Icon(icon, color: Colors.white60, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}