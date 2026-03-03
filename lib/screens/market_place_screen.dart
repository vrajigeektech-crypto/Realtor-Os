import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../layout/main_layout.dart';
import 'package:get/get.dart';
import 'controller/marketplace_controller.dart';

class MarketPlaceScreen extends StatelessWidget {
  const MarketPlaceScreen({super.key});

  final Color accentColor = const Color(0xFFCE9799); // Rose Gold
  final Color borderColor = const Color(0xFF4A3436); // Dark Copper
  final Color bgDark = const Color(0xFF0A0A0A);
  final Color cardColor = const Color(0xFF161616);

  @override
  Widget build(BuildContext context) {
    Get.put(MarketplaceController());
    return MainLayout(
      activeIndex: 11,
      title: 'Market Place',
      headerExtras: [
        Obx(() {
          final controller = Get.find<MarketplaceController>();
          return Row(
            children: [
              _buildHeaderStat(
                '${controller.availableBalance.value}',
                'Available Balance',
                Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(width: 16),
              _buildHeaderStat(
                '${controller.ostBalance.value}',
                'OST',
                Icons.token,
              ),
            ],
          );
        }),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Metallic Bar
              _buildMetallicBar(isTop: true),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainHeader(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('This Week\'s Plan', Icons.bar_chart),
                    const SizedBox(height: 8),
                    Text(
                      'Selected for you based on your listings, buyers, and current market activity.',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildPlanScrollList(),
                    const SizedBox(height: 40),
                    _buildReasonsSection(),
                    const SizedBox(height: 40),
                    _buildNextStepsSection(),
                  ],
                ),
              ),

              // Bottom Metallic Bar
              _buildMetallicBar(isTop: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetallicBar({required bool isTop}) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isTop ? const Radius.circular(20) : Radius.zero,
          bottom: isTop ? Radius.zero : const Radius.circular(20),
        ),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A2A), Color(0xFF5A4A4C), Color(0xFF2A2A2A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: isTop
            ? Border(bottom: BorderSide(color: borderColor.withOpacity(0.5)))
            : null,
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 16),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMainHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Here\'s What You Should Do This Week',
          style: GoogleFonts.inter(
            color: const Color(0xFFE0E0E0), // Slightly off-white/gold
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selected for you based on your listings, buyers, and current market activity.',
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFC6A87C), size: 24), // Gold-ish icon
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            color: const Color(0xFFC6A87C),
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanScrollList() {
    final controller = Get.find<MarketplaceController>();
    return Obx(() {
      if (controller.isLoadingRecommendations.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.recommendations.isEmpty) {
        return Text(
          'No recommendations for this week.',
          style: GoogleFonts.inter(color: Colors.white54),
        );
      }

      return SizedBox(
        height: 360, // Fixed height for the cards
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.recommendations.map((item) {
              // Map RPC data to UI model
              IconData icon = Icons.api;
              String platform = item['platform'] ?? 'Unknown';
              if (platform.toLowerCase().contains('tiktok')) {
                icon = Icons
                    .music_note; // Using standard material icons as requested
              }
              if (platform.toLowerCase().contains('instagram')) {
                icon = Icons.camera_alt;
              }
              if (platform.toLowerCase().contains('youtube')) {
                icon = Icons.play_arrow;
              }
              if (platform.toLowerCase().contains('linkedin')) {
                icon = Icons.business;
              }
              if (platform.toLowerCase().contains('call')) {
                icon = Icons.phone_in_talk;
              }

              return _buildPlanCard({
                'platform': platform,
                'icon': icon,
                'title': item['title'] ?? 'Recommendation',
                'desc': item['category'] ?? 'Suggested Action',
                'badge': item['status'] ?? 'Draft',
                'tokens': item['token_cost'] ?? 1,
                'image': _getImageForPlatform(platform),
                'isImage': true, // Always show image for now
              });
            }).toList(),
          ),
        ),
      );
    });
  }

  String _getImageForPlatform(String platform) {
    if (platform.toLowerCase().contains('tiktok')) {
      return 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=1000&auto=format&fit=crop';
    }
    if (platform.toLowerCase().contains('instagram')) {
      return 'https://images.unsplash.com/photo-1611162616475-46b635cb6868?q=80&w=1000&auto=format&fit=crop';
    }
    if (platform.toLowerCase().contains('youtube')) {
      return 'https://images.unsplash.com/photo-1611162616475-46b635cb6868?q=80&w=1000&auto=format&fit=crop';
    }
    if (platform.toLowerCase().contains('linkedin')) {
      return 'https://images.unsplash.com/photo-1616469829581-73993eb86b02?q=80&w=1000&auto=format&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?q=80&w=1000&auto=format&fit=crop';
  }

  Widget _buildPlanCard(Map<String, dynamic> data) {
    return Container(
      width: 280,
      height: 340,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        image: data['isImage'] == true || data['isChart'] == true
            ? DecorationImage(
                image: NetworkImage(data['image'] ?? ''),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Stack(
        children: [
          // Content Overlay
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Icon + Name)
                Row(
                  children: [
                    Icon(data['icon'], color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      data['platform'],
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                // Middle Section (Stats or Spacer)
                if (data['isStat'] == true) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Current Market',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['stat'],
                    style: GoogleFonts.inter(
                      color: Colors.greenAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    data['statDesc'],
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                ] else if (data['isChart'] == true) ...[
                  const Spacer(), // Placeholder for chart visual
                ] else ...[
                  const Spacer(),
                ],

                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(data['badge']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (data['badge'] == 'Ready')
                        const Icon(
                          Icons.check_circle,
                          color: Colors.black,
                          size: 12,
                        ),
                      if (data['badge'] == 'Ready') const SizedBox(width: 4),
                      Text(
                        data['badge'],
                        style: GoogleFonts.inter(
                          color: _getBadgeTextColor(data['badge']),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Title & Desc
                Text(
                  data['title'],
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data['desc'],
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Action Button
                GestureDetector(
                  onTap: () {
                    if (data['badge'] != 'In Progress' && data['id'] != null) {
                      final controller = Get.find<MarketplaceController>();
                      controller.approveAndPostRecommendation(
                        data['id'].toString(),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC6A87C), Color(0xFFA6885C)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC6A87C).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        data['badge'] == 'In Progress'
                            ? 'View Progress'
                            : 'Approve & Post',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Token Cost
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.token,
                        color: const Color(0xFFC6A87C),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${data['tokens']} tokens',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFC6A87C),
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
        ],
      ),
    );
  }

  Color _getBadgeColor(String badge) {
    if (badge == 'Ready') return const Color(0xFFA4C639); // Lime Green
    if (badge == 'In Progress') return const Color(0xFFCE9799); // Rose Gold
    return Colors.white24;
  }

  Color _getBadgeTextColor(String badge) {
    if (badge == 'Ready') return Colors.black;
    if (badge == 'In Progress') return Colors.black;
    return Colors.white;
  }

  Widget _buildReasonsSection() {
    final controller = Get.find<MarketplaceController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why These Were Selected',
          style: GoogleFonts.inter(
            color: const Color(0xFFE0E0E0),
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.insights.isEmpty) {
            return Text(
              'No insights available.',
              style: GoogleFonts.inter(color: Colors.white24),
            );
          }
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: controller.insights.map((item) {
              IconData icon = Icons.lightbulb_outline;
              final iconStr = item['icon'] as String? ?? '';
              if (iconStr == 'list') icon = Icons.list;
              if (iconStr == 'handshake-slash') {
                icon = Icons.handshake_outlined; // approximate
              }
              if (iconStr == 'trending-up') icon = Icons.trending_up;
              if (iconStr == 'trending-down') icon = Icons.trending_down;

              return _buildReasonChip(item['label'] ?? 'Insight', icon);
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildReasonChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepsSection() {
    final controller = Get.find<MarketplaceController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What You Can Activate Next',
          style: GoogleFonts.inter(
            color: const Color(0xFFE0E0E0),
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.activationCategories.isEmpty) {
            return Text(
              'No activation categories available.',
              style: GoogleFonts.inter(color: Colors.white24),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              // Responsive Grid: 4 columns on wide, 2 on medium, 1 on small
              int crossAxisCount = constraints.maxWidth > 1100
                  ? 4
                  : constraints.maxWidth > 600
                  ? 2
                  : 1;
              double width =
                  (constraints.maxWidth - ((crossAxisCount - 1) * 20)) /
                  crossAxisCount;

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: controller.activationCategories
                    .map(
                      (category) => SizedBox(
                        width: width,
                        child: _buildNextStepCard({
                          'title': category['category_name'] ?? 'Category',
                          'desc': category['description'] ?? '',
                          'status': category['status'] ?? 'active',
                          'icon': _getIconForCategory(
                            (category['icon'] ?? 'circle').toString(),
                          ),
                          'isChecked': category['is_active'] == true,
                          'action': category['status'] == 'reserved'
                              ? 'Reserved'
                              : null,
                        }),
                      ),
                    )
                    .toList(),
              );
            },
          );
        }),
      ],
    );
  }

  IconData _getIconForCategory(String iconName) {
    switch (iconName) {
      case 'megaphone':
        return Icons.campaign;
      case 'graduation-cap':
        return Icons.school;
      case 'magnet':
        return Icons.filter_alt;
      case 'refresh':
        return Icons.restore;
      default:
        return Icons.circle;
    }
  }

  Widget _buildNextStepCard(Map<String, dynamic> step) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(step['icon'], color: const Color(0xFFC6A87C), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  step['title'],
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (step['isChecked'] == true)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFFA4C639),
                  size: 20,
                ),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            step['desc'],
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (step.containsKey('action') && step['action'] != null)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  step['action'].toString(),
                  style: GoogleFonts.inter(
                    color: const Color(0xFFC6A87C),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
