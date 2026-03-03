import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'agent_detail_host_screen.dart';
class AgentDetailProfileScreen extends StatelessWidget {
  const AgentDetailProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AgentDetailHostScreen(initialTabIndex: 0);
  }
}

class AgentProfileContent extends StatefulWidget {
  const AgentProfileContent({super.key});

  @override
  State<AgentProfileContent> createState() => _AgentProfileContentState();
}

class _AgentProfileContentState extends State<AgentProfileContent> {
  int _subTabIndex = 0; // "Profile" sub-tab

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        final isTablet =
            constraints.maxWidth >= 900 && constraints.maxWidth < 1200;

        // On mobile and tablet, hide sidebar data below profile
        if (isMobile || isTablet) {
          return _buildMainContent()
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 380, child: _buildSidebar())
                .animate()
                .fadeIn(duration: 500.ms)
                .slideX(begin: -0.1, end: 0, curve: Curves.easeOutCubic),
            Container(width: 1, color: Colors.white10),
            Expanded(
              child: _buildMainContent()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 150.ms)
                  .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebar() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Image.network(
                'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=400',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Jessica Reynolds',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppStyles.copperGradient,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Team Lead',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const _SidebarLabel('Prestige Realty Group'),
        const _SidebarLabel('Elite Team'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(color: Colors.white10, height: 1),
        ),
        const _SidebarRow('Agent ID:', 'AGT-21456'),
        const _SidebarRow('Joined:', 'Mar 12, 2018'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status:',
                style: TextStyle(color: AppStyles.mutedText, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3D2A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF2D6346)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF35C86B), size: 6),
                    SizedBox(width: 8),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Color(0xFF35C86B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const _SidebarRow('Last Login:', 'Jan 15, 2024, 10:22 AM'),
      ],
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildTabs(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(48),
            children: [
              _buildProfileDetailRow('Email:', 'jessica.reynolds@email.com'),
              _buildProfileDetailRow('Phone:', '+1 (555) 123-9876'),
              _buildProfileDetailRow('License Number:', 'LIC-987654'),
              _buildProfileDetailRow('Years of Experience:', '8 Years'),
              _buildProfileDetailRow(
                'Specialties:',
                'Residential, Luxury Homes',
              ),
              _buildProfileDetailRow('Office Location:', 'Los Angeles, CA'),
              _buildProfileDetailRow(
                'Bio:',
                'Experienced real estate professional dedicated to exceptional client service and results.',
                isLongText: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final tabs = ['Profile', 'Listings', 'Transactions', 'Activity'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs
              .asMap()
              .entries
              .map(
                (e) => InkWell(
                  onTap: () => setState(() => _subTabIndex = e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: e.key == _subTabIndex
                          ? Colors.white.withValues(alpha: 0.02)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: e.key == _subTabIndex
                              ? AppStyles.accentRose
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: e.key == _subTabIndex
                            ? Colors.white
                            : AppStyles.mutedText,
                        fontSize: 14,
                        fontWeight: e.key == _subTabIndex
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(
    String label,
    String value, {
    bool isLongText = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: AppStyles.mutedText,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 160,
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: AppStyles.mutedText,
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
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const Divider(color: Colors.white10, height: 1),
          ],
        );
      },
    );
  }
}

class _SidebarLabel extends StatelessWidget {
  final String label;
  const _SidebarLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        label,
        style: const TextStyle(color: AppStyles.mutedText, fontSize: 14),
      ),
    );
  }
}

class _SidebarRow extends StatelessWidget {
  final String label, value;
  const _SidebarRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppStyles.mutedText, fontSize: 13),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
