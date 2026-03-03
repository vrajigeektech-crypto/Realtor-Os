import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/content_card.dart';
import '../screens/review_recommendation_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _navigateToReview(BuildContext context, Map<String, dynamic> recommendation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewRecommendationScreen(recommendation: recommendation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2A1F1F),
                      const Color(0xFF1A1414),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFCE9799).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCE9799).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dashboard_rounded,
                            color: Color(0xFFCE9799),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome back to your Dashboard",
                                style: TextStyle(
                                  color: const Color(0xFFCE9799),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Here's What You Should Do This Week",
                                style: TextStyle(
                                  color: Color(0xFFEBE3DE),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Selected for you based on your listings, buyers, and current market activity.",
                      style: TextStyle(
                        color: const Color(0xFF8C817C),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- SUBHEADER ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1616),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFCE9799).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A373).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: Color(0xFFD4A373),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "This Week's Plan",
                      style: TextStyle(
                        color: Color(0xFFD3CFCF),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 8,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "5 Active",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- HORIZONTAL SCROLLING CARDS (THE 5 GROUPS) ---
              SizedBox(
                height: 540,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior:
                      Clip.none, // Allows shadows to paint outside bounds
                  children: [
                    // 1. TikTok Card
                    ContentCard(
                      platform: "TikTok",
                      imageUrl: "assets/images/img_tiktok_woman.jpg",
                      title: "TikTok Listing Walkthrough",
                      status: "Ready",
                      tokens: 5,
                      onApprove: () => _navigateToReview(context, {
                        'id': '1',
                        'title': 'TikTok Listing Walkthrough',
                        'platform': 'TikTok',
                        'category': 'Social Media Content',
                        'token_cost': 5,
                        'status': 'Ready',
                        'description': 'Create engaging TikTok walkthrough of your latest listing',
                      }),
                    ),  

                    // 2. Instagram Card
                    ContentCard(
                      platform: "Instagram",
                      imageUrl: "assets/images/img_graph_bg.jpg",
                      title: "Instagram Market Insight",
                      status: "Ready",
                      tokens: 3,
                      onApprove: () => _navigateToReview(context, {
                        'id': '2',
                        'title': 'Instagram Market Insight',
                        'platform': 'Instagram',
                        'category': 'Market Update',
                        'token_cost': 3,
                        'status': 'Ready',
                        'description': 'Share latest market trends with your Instagram followers',
                      }),
                    ),

                    // 3. YouTube Shorts Card
                    ContentCard(
                      platform: "YouTube Shorts",
                      imageUrl: "assets/images/img_youtube_woman.jpg",
                      title: "Buyer Tip Walkthrough",
                      status: "Ready",
                      tokens: 4,
                      onApprove: () => _navigateToReview(context, {
                        'id': '3',
                        'title': 'Buyer Tip Walkthrough',
                        'platform': 'YouTube Shorts',
                        'category': 'Educational Content',
                        'token_cost': 4,
                        'status': 'Ready',
                        'description': 'Help first-time buyers with essential tips',
                      }),
                    ),

                    // 4. LinkedIn Card
                    ContentCard(
                      platform: "LinkedIn",
                      imageUrl: "assets/images/img_audio_wave.jpg",
                      title: "AI Calling Campaign",
                      status: "In Progress",
                      tokens: 2,
                      onApprove: () => _navigateToReview(context, {
                        'id': '4',
                        'title': 'AI Calling Campaign',
                        'platform': 'LinkedIn',
                        'category': 'Lead Generation',
                        'token_cost': 2,
                        'status': 'In Progress',
                        'description': 'AI-powered calling campaign for qualified leads',
                      }),
                    ),

                    // 5. AI Calling Card
                    ContentCard(
                      platform: "AI Calling",
                      imageUrl: "assets/images/img_office_bg.jpg",
                      title: "AI Calling Campaign",
                      status: "Ready",
                      tokens: 8,
                      onApprove: () => _navigateToReview(context, {
                        'id': '5',
                        'title': 'AI Calling Campaign',
                        'platform': 'AI Calling',
                        'category': 'Lead Generation',
                        'token_cost': 8,
                        'status': 'Ready',
                        'description': 'AI-powered calling campaign for qualified leads',
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // --- SECTION: WHY THESE WERE SELECTED ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1616),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFCE9799).withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCE9799).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Color(0xFFCE9799),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Why These Were Selected",
                          style: TextStyle(
                            color: Color(0xFFD3CFCF),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _ReasonBadge(
                          icon: Icons.list_alt_rounded,
                          text: "Active listing detected",
                        ),
                        _ReasonBadge(
                          icon: Icons.people_outline_rounded,
                          text: "Buyer engagement slowing",
                        ),
                        _ReasonBadge(
                          icon: Icons.trending_up_rounded,
                          text: "Market activity increased",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // --- SECTION: WHAT YOU CAN ACTIVATE NEXT ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1616),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFCE9799).withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCE9799).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: Color(0xFFCE9799),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "What You Can Activate Next",
                          style: TextStyle(
                            color: Color(0xFFD3CFCF),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Grid of 4 small cards
                    GridView.count(
                      shrinkWrap: true, // Important for scrolling inside Column
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2, // 2 cards per row
                      childAspectRatio: 1.6, // Width/Height ratio
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _NextStepCard(
                          title: "Market Presence",
                          subtitle: "Requires Approval",
                          icon: Icons.storefront_rounded,
                        ),
                        _NextStepCard(
                          title: "Education",
                          subtitle: "Improve listings and branding",
                          icon: Icons.school_rounded,
                        ),
                        _NextStepCard(
                          title: "Lead Generation",
                          subtitle: "Build lead capture and nurturing",
                          icon: Icons.cloud_download_rounded,
                        ),
                        _NextStepCard(
                          title: "Lead Recovery",
                          subtitle: "Revitalize older relationships",
                          icon: Icons.history_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32), // Bottom padding for better layout
            ],
          ),
        ),
      ),
    );
  }
}

// --- HELPER WIDGETS (Put these at bottom of file or in separate files) ---

class _ReasonBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ReasonBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF231819),
            const Color(0xFF2A1F1F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5E3C).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5E3C).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8B5E3C),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFE8E0D8),
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

class _NextStepCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _NextStepCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1616),
            const Color(0xFF2A1F1F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFCE9799).withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5E3C).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8B5E3C),
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFAFAFAF),
              fontSize: 13,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
