import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../layout/main_layout.dart';
import '../core/app_colors.dart';
import '../services/linkedin_marketplace_service.dart';
import '../services/recommendation_service.dart';
import '../utils/app_styles.dart';

class LinkedInRecommendationScreen extends StatefulWidget {
  final Map<String, dynamic> recommendation;

  const LinkedInRecommendationScreen({
    super.key,
    required this.recommendation,
  });

  @override
  State<LinkedInRecommendationScreen> createState() => _LinkedInRecommendationScreenState();
}

class _LinkedInRecommendationScreenState extends State<LinkedInRecommendationScreen> {
  final LinkedInMarketplaceService _linkedinService = LinkedInMarketplaceService();
  final RecommendationService _recommendationService = RecommendationService();
  bool _isLaunching = false;
  double _currentBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    // Load user balance (mock for now)
    setState(() {
      _currentBalance = 8021.0;
    });
  }

  Future<void> _launchWorkflow() async {
    setState(() {
      _isLaunching = true;
    });

    try {
      final userId = 'fc6183ec-f307-4a34-a101-e805b6975699'; // Mock user ID
      final tokenCost = widget.recommendation['token_cost'] as int;
      final promotionId = widget.recommendation['id'] as String;
      final promotionTitle = widget.recommendation['title'] as String;

      // Check balance
      if (_currentBalance < tokenCost) {
        _showInsufficientBalanceDialog(tokenCost);
        return;
      }

      // Purchase the recommendation (deduct tokens and add to queue)
      final queueItem = await _recommendationService.purchasePromotion(
        userId: userId,
        promotionId: promotionId,
        promotionTitle: promotionTitle,
        tokenCost: tokenCost,
      );

      if (queueItem == null) {
        throw Exception('Failed to launch workflow');
      }

      // Show success dialog
      _showSuccessDialog();

      // Update balance
      setState(() {
        _currentBalance -= tokenCost;
      });

    } catch (e) {
      _showErrorDialog('Failed to launch workflow: ${e.toString()}');
    } finally {
      setState(() {
        _isLaunching = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Workflow Launched!',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Your ${widget.recommendation['title']} has been added to your approval queue. You\'ll receive a notification when it\'s ready for review.',
          style: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Great!',
              style: GoogleFonts.inter(
                color: const Color(0xFFCE9799),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInsufficientBalanceDialog(int requiredTokens) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Insufficient Balance',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'You need $requiredTokens OST tokens to launch this workflow. Your current balance is ${_currentBalance.toInt()} OST.',
          style: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: GoogleFonts.inter(
                color: const Color(0xFFCE9799),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Error',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                color: const Color(0xFFCE9799),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      activeIndex: 15,
      title: widget.recommendation['title'],
      child: Container(
        decoration: AppStyles.fidelityBackgroundDecoration(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildWhatThisIs(),
              const SizedBox(height: 40),
              _buildWhyThisIsShowing(),
              const SizedBox(height: 40),
              _buildWhatYouGet(),
              const SizedBox(height: 40),
              _buildExecutionDetails(),
              const SizedBox(height: 40),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A3436)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFCE9799).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'LinkedIn',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCE9799),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.recommendation['status'] ?? 'Ready',
                  style: GoogleFonts.inter(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.recommendation['title'],
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.recommendation['description'] ?? '',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFCE9799).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCE9799)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Color(0xFFCE9799),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.recommendation['token_cost']} OST',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFCE9799),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.recommendation['xp_reward']} XP',
                      style: GoogleFonts.inter(
                        color: Colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A3436)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatThisIs() {
    return _buildSection(
      'What This Is',
      widget.recommendation['what_this_is'] ?? 'Detailed information about this service.',
    );
  }

  Widget _buildWhyThisIsShowing() {
    return _buildSection(
      'Why This Is Showing',
      widget.recommendation['why_this_is_showing'] ?? 'Reasons why this service is recommended for you.',
    );
  }

  Widget _buildWhatYouGet() {
    final whatYouGet = widget.recommendation['what_you_get'] as List<String>? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A3436)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What You Get',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...whatYouGet.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4, right: 12),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCE9799),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildExecutionDetails() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A3436)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Execution Details',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Execution Type', widget.recommendation['execution_type'] ?? ''),
          _buildDetailRow('Format', widget.recommendation['format'] ?? ''),
          _buildDetailRow('Posting', widget.recommendation['posting'] ?? ''),
          _buildDetailRow('Turnaround', widget.recommendation['turnaround'] ?? ''),
          _buildDetailRow('Platform', widget.recommendation['platform'] ?? ''),
          _buildDetailRow('Reuse', widget.recommendation['reuse'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLaunching ? null : _launchWorkflow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCE9799),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLaunching
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Launching...',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    widget.recommendation['primary_action'] ?? 'Launch Workflow',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implement view sample
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCE9799)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'View Sample',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCE9799),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implement adjust settings
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCE9799)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Adjust Settings',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCE9799),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Skip for Now',
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
