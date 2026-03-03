import 'package:flutter/material.dart';

class GoogleIntegrationsScreen extends StatelessWidget {
  const GoogleIntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _GoogleIntegrationsLayout();
  }
}

class _GoogleIntegrationsLayout extends StatelessWidget {
  const _GoogleIntegrationsLayout();

  @override
  Widget build(BuildContext context) {
    const divider = Color(0xFF3E3144);
    const accentRose = Color(0xFFCE9799);
    const muted = Color(0xFF9EA3AE);

    final cards = <_GoogleIntegrationCardModel>[
      const _GoogleIntegrationCardModel(
        title: 'Google Calendar',
        subtitle: 'Sync events with your calendar',
        status: _Status.connected,
        buttonLabel: 'Connected',
        icon: Icons.calendar_month_outlined,
      ),
      const _GoogleIntegrationCardModel(
        title: 'Google My Business',
        subtitle: 'Manage customer reviews & business info',
        status: _Status.notConnected,
        buttonLabel: 'Connect',
        icon: Icons.storefront_outlined,
      ),
      const _GoogleIntegrationCardModel(
        title: 'Google Contacts',
        subtitle: 'Access and sync your contacts',
        status: _Status.notConnected,
        buttonLabel: 'Connect',
        icon: Icons.contacts_outlined,
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              // _TopBar(), // Handled by MainLayout
              const Text(
                'Google Integrations',
                style: TextStyle(
                  color: accentRose,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Link your Google account.',
                style: TextStyle(
                  color: muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              const Divider(color: divider),
              const SizedBox(height: 26),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final width = c.maxWidth;
                    final gap = 18.0;

                    // Match 3-card row on desktop; collapse to 2/1 on smaller screens.
                    int cols;
                    if (width >= 980) {
                      cols = 3;
                    } else if (width >= 640) {
                      cols = 2;
                    } else {
                      cols = 1;
                    }

                    final cardWidth = (width - gap * (cols - 1)) / cols;
                    const cardHeight = 300.0;

                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (final m in cards)
                            SizedBox(
                              width: cardWidth,
                              height: cardHeight,
                              child: _GoogleIntegrationCard(model: m),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Status { connected, notConnected }

class _GoogleIntegrationCardModel {
  final String title;
  final String subtitle;
  final _Status status;
  final String buttonLabel;
  final IconData icon;

  const _GoogleIntegrationCardModel({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.buttonLabel,
    required this.icon,
  });
}

class _GoogleIntegrationCard extends StatelessWidget {
  final _GoogleIntegrationCardModel model;
  const _GoogleIntegrationCard({required this.model});

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFF3E3144);
    const muted = Color(0xFF9EA3AE);
    const accent = Color(0xFFCE9799);
    const ok = Color(0xFF35C86B);
    const cardBg = Color(0xFF1E1E1E);

    final isConnected = model.status == _Status.connected;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 74,
            width: 74,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Icon(model.icon, color: accent, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            model.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            model.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          if (isConnected)
            SizedBox(
              height: 36,
              width: 160,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ok.withValues(alpha: 0.6)),
                  backgroundColor: ok.withValues(alpha: 0.10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: ok),
                    const SizedBox(width: 8),
                    Text(
                      'Connected',
                      style: TextStyle(
                        color: ok,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 36,
              width: 160,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accent.withValues(alpha: 0.65)),
                  backgroundColor: Colors.white.withValues(alpha: 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  'Connect',
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
