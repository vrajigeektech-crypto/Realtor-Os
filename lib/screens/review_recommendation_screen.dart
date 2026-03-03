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
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final tokenCost = widget.recommendation['token_cost'] ?? 5;
      
      // Check balance
      if (_currentBalance < tokenCost) {
        _showInsufficientBalanceDialog(tokenCost);
        return;
      }

      // Purchase the recommendation (deduct tokens and add to queue)
      final queueItem = await _recommendationService.purchasePromotion(
        userId: userId,
        promotionId: widget.recommendation['id'].toString(),
        promotionTitle: widget.recommendation['title'] ?? 'AI Workflow',
        tokenCost: tokenCost,
      );

      if (queueItem == null) {
        throw Exception('Failed to launch workflow');
      }

      // Show success dialog
      _showSuccessDialog();

      // Update balance
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
        title: const Text(
          'Insufficient Balance',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You need $requiredTokens tokens to launch this workflow.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              'Current balance: ${_currentBalance.toInt()} tokens',
              style: const TextStyle(color: AppColors.roseGold),
            ),
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
                  builder: (context) => const MainLayout(
                    activeIndex: 2,
                    child: SizedBox(), // Placeholder child
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roseGold,
              foregroundColor: Colors.black,
            ),
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
        title: const Text(
          'Workflow Launched!',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Your workflow has been added to the automation queue.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'It will be processed automatically.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to dashboard
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roseGold,
              foregroundColor: Colors.black,
            ),
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
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: AppColors.roseGold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokenCost = widget.recommendation['token_cost'] ?? 5;
    final platform = widget.recommendation['platform'] ?? 'AI';
    final title = widget.recommendation['title'] ?? 'AI Workflow';
    final description = widget.recommendation['category'] ?? 'Automated Task';

    return MainLayout(
      activeIndex: 11, // Marketplace index
      title: 'Review Recommendation',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF4A3436), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.roseGold.withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Metallic Bar
              Container(
                height: 12,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2A2A2A),
                      Color(0xFF5A4A4C),
                      Color(0xFF2A2A2A),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.roseGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.roseGold),
                          ),
                          child: const Text(
                            'AI-Cloned - Your Voice',
                            style: TextStyle(
                              color: AppColors.roseGold,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'READY FOR APPROVAL',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Phone Preview
                    Center(
                      child: Container(
                        width: 280,
                        height: 500,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade800),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Phone Status Bar
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      '9:41',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.signal_cellular_alt, color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Icon(Icons.wifi, color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Icon(Icons.battery_full, color: Colors.white, size: 12),
                                      SizedBox(width: 20),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Phone Content
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.roseGold.withOpacity(0.1),
                                      Colors.black.withOpacity(0.9),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Profile Section
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundColor: AppColors.roseGold,
                                        child: const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Jessica Williams',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Your Local Realtor',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Content Card
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                                        ),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Weekly Market Insight',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Posted as You',
                                              style: TextStyle(
                                                color: AppColors.roseGold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              height: 120,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.play_circle,
                                                  color: Colors.white70,
                                                  size: 40,
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
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // What This Is Section
                    _buildSection(
                      'What This Is',
                      'The "$title" is a short, professional video designed to keep you visible, credible, and relevant without manual effort. Perfect for maintaining consistent social media presence.',
                    ),

                    const SizedBox(height: 24),

                    // Why This Is Showing Section
                    _buildSection(
                      'Why This Is Showing',
                      'Based on your current activity:\n• Active buyers and listings in your pipeline\n• No recent educational or market content posted\n• Maintaining visibility is crucial for lead generation',
                    ),

                    const SizedBox(height: 24),

                    // What You Get Section
                    _buildSection(
                      'What You Get',
                      '• Custom script tailored to your voice\n• AI voice clone for authentic delivery\n• Professional branded visuals\n• Platform-specific formatting\n• Added to your posting queue\n\nNothing posts without your confirmation.',
                    ),

                    const SizedBox(height: 32),

                    // Execution Details
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4A3436)),
                      ),
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
                          const SizedBox(height: 16),
                          _buildDetailRow('Execution Type', 'AI-Generated - Agent-Branded'),
                          _buildDetailRow('Posting', 'Manual approval required'),
                          _buildDetailRow('Turnaround', 'Within 24 hours'),
                          _buildDetailRow('Platforms', platform),
                          _buildDetailRow('Reuse', 'Can also be sent directly to clients'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Token Cost and Rewards
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161616),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF4A3436)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Token Cost',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.token,
                                      color: AppColors.roseGold,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$tokenCost OST',
                                      style: const TextStyle(
                                        color: AppColors.roseGold,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161616),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF4A3436)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rewards',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '+2 XP',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Counts toward weekly consistency',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      'Improves Operational Trust Level',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Launch Workflow Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLaunching ? null : _launchWorkflow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.roseGold,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLaunching
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Launching...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Launch Workflow',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Additional Options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'View Sample Output',
                            style: TextStyle(color: AppColors.roseGold),
                          ),
                        ),
                        const Text(' • ', style: TextStyle(color: Colors.white24)),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Change Platform Selection',
                            style: TextStyle(color: AppColors.roseGold),
                          ),
                        ),
                        const Text(' • ', style: TextStyle(color: Colors.white24)),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Skip for Now',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Bottom Metallic Bar
              Container(
                height: 12,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2A2A2A),
                      Color(0xFF5A4A4C),
                      Color(0xFF2A2A2A),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
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
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
