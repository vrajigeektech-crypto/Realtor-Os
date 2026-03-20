// lib/screens/integrations_screen.dart
import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class IntegrationsScreen extends StatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen> {
  int _selectedTabIndex = 4; // 'Integrations'

  @override
  Widget build(BuildContext context) {
    // Project palette approximation based on provided code
    const dividerColor = Color(0xFF2B2D31);

    return MainLayout(
      title: 'Integrations',
      activeIndex:
          6, // Settings or Admin index in MainLayout sidebar? Integrations wasn't explicitly there but let's approximate
      child: Column(
        children: [
          _AgentHeader(),
          const SizedBox(height: 8),
          _TopTabs(
            selectedIndex: _selectedTabIndex,
            onTabSelected: (index) => setState(() => _selectedTabIndex = index),
          ),
          const Divider(height: 1, color: dividerColor),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                const _SectionTitle('CRM Integrations'),
                const SizedBox(height: 12),
                _IntegrationGrid(
                  children: const [
                    IntegrationCard(
                      title: 'Follow Up Boss',
                      statusLabel: 'Connected',
                      isConnected: true,
                      lastSynced: 'Last Synced: 2 hours ago',
                      accountMasked: '**** ···· ···· 9264',
                      buttonLabel: 'View Settings',
                    ),
                    IntegrationCard(
                      title: 'KV Core',
                      statusLabel: 'Connected',
                      isConnected: true,
                      lastSynced: 'Last Synced: 3 hours ago',
                      accountMasked: '**** ···· ···· 3512',
                      buttonLabel: 'View Settings',
                    ),
                    IntegrationCard(
                      title: 'LionDesk',
                      statusLabel: 'Connected',
                      isConnected: true,
                      lastSynced: 'Last Synced: 1 hour ago',
                      accountMasked: '**** ···· ···· 1743',
                      buttonLabel: 'View Settings',
                    ),
                    IntegrationCard(
                      title: 'Chime',
                      statusLabel: 'Not Connected',
                      isConnected: false,
                      lastSynced: 'Last Synced: 5 days ago',
                      accountMasked: '**** ···· ···· 4897',
                      buttonLabel: 'View Settings',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const _SectionTitle('Social Media Connections'),
                const SizedBox(height: 12),
                _IntegrationGrid(
                  children: const [
                    SocialConnectionCard(
                      title: 'Facebook',
                      statusLabel: 'Connected',
                      lastActivity: 'Last Activity: 30 minutes ago',
                      permissionLabel: 'Read / Post',
                    ),
                    SocialConnectionCard(
                      title: 'Instagram',
                      statusLabel: 'Connected',
                      lastActivity: 'Last Activity: 1 hour ago',
                      permissionLabel: 'Read / Post / Full',
                    ),
                    SocialConnectionCard(
                      title: 'LinkedIn',
                      statusLabel: 'Connected',
                      lastActivity: 'Last Activity: 45 minutes ago',
                      permissionLabel: 'Read / Post',
                    ),
                    SocialConnectionCard(
                      title: 'YouTube',
                      statusLabel: 'Connected',
                      lastActivity: 'Last Activity: 2 hours ago',
                      permissionLabel: 'Read / Post',
                    ),
                    SocialConnectionCard(
                      title: 'TikTok',
                      statusLabel: 'Connected',
                      lastActivity: 'Last Activity: 15 minutes ago',
                      permissionLabel: 'Read / Post',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AgentIntegrationsContent extends StatelessWidget {
  const AgentIntegrationsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Integrations content coming soon',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}

class _AgentHeader extends StatelessWidget {
  const _AgentHeader();
  @override
  Widget build(BuildContext context) {
    const roseGold = Color(0xFFCE9799); // Project Accent
    const mutedText = Color(0xFF9EA3AE);

    // We can conditionally hide this on mobile if MainLayout's header covers it,
    // but the Agent Header is content-specific (Agent Name), so we keep it.

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: roseGold, width: 1),
              color: Colors.white24,
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Michael Carter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Agent | Prestige Realty Group',
                  style: TextStyle(color: mutedText, fontSize: 13),
                ),
              ],
            ),
          ),
          // const _ActivePill(), // Removed to simplify responsive layout in MainLayout shell
        ],
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  const _TopTabs({required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    const mutedText = Color(0xFF9EA3AE);
    const roseGold = Color(0xFFCE9799); // Project Accent
    final tabs = [
      'Profile',
      'Wallet & Tokens',
      'Usage',
      'Tasks & Queue',
      'Integrations',
      'Assets',
      'Onboarding',
      'Security',
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isActive = index == selectedIndex;
          return Center(
            child: InkWell(
              onTap: () => onTabSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: isActive
                    ? const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: roseGold, width: 2),
                        ),
                      )
                    : null,
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: isActive ? Colors.white : mutedText,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 16),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);
  @override
  Widget build(BuildContext context) {
    const mutedText = Color(0xFF9EA3AE);
    return Text(
      label,
      style: const TextStyle(
        color: mutedText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _IntegrationGrid extends StatelessWidget {
  final List<Widget> children;
  const _IntegrationGrid({required this.children});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 600;
        final isTablet = width >= 600 && width <= 900;

        // Calculate card width
        // Assumes padding of 24 on left/right in parent ListView
        // However, inside LayoutBuilder `constraints.maxWidth` is the available width.
        // If parent has padding, constraints are already reduced.
        // Let's assume we want to fill the width.

        double cardWidth;
        int crossAxisCount;

        if (isMobile) {
          crossAxisCount = 1;
        } else if (isTablet) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 4;
        }

        final spacing = 16.0;
        final availableWidth = width;

        cardWidth =
            (availableWidth - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;
        // Safety check
        if (cardWidth < 200) cardWidth = availableWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((c) => SizedBox(width: cardWidth, child: c))
              .toList(),
        );
      },
    );
  }
}

class IntegrationCard extends StatelessWidget {
  final String title;
  final String statusLabel;
  final bool isConnected;
  final String lastSynced;
  final String accountMasked;
  final String buttonLabel;
  const IntegrationCard({
    super.key,
    required this.title,
    required this.statusLabel,
    required this.isConnected,
    required this.lastSynced,
    required this.accountMasked,
    required this.buttonLabel,
  });
  @override
  Widget build(BuildContext context) {
    const cardBackground = Color(0xFF1E1E1E); // Project Card BG
    const roseGold = Color(0xFFCE9799); // Project Accent
    const mutedText = Color(0xFF9EA3AE);
    final statusColor = isConnected ? Colors.greenAccent : roseGold;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.cloud_sync_outlined,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: statusColor),
              const SizedBox(width: 6),
              Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            lastSynced,
            style: const TextStyle(color: mutedText, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            accountMasked,
            style: const TextStyle(
              color: mutedText,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 32,
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isConnected
                      ? Colors.white24
                      : roseGold.withValues(alpha: 0.8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Navigating to settings for $title'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SocialConnectionCard extends StatelessWidget {
  final String title;
  final String statusLabel;
  final String lastActivity;
  final String permissionLabel;
  const SocialConnectionCard({
    super.key,
    required this.title,
    required this.statusLabel,
    required this.lastActivity,
    required this.permissionLabel,
  });
  @override
  Widget build(BuildContext context) {
    const cardBackground = Color(0xFF1E1E1E); // Project Card BG
    const mutedText = Color(0xFF9EA3AE);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.apps, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.circle, size: 10, color: Colors.greenAccent),
              SizedBox(width: 6),
              Text(
                'Connected',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            lastActivity,
            style: const TextStyle(color: mutedText, fontSize: 11),
          ),
          // Spacer(), // Spacer in Wrap/ListView can be tricky usually better to use SizedBox with height if known or Flex
          const SizedBox(height: 20),
          Text(
            permissionLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
