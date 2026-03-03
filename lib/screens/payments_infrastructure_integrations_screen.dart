import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class PaymentsInfrastructureIntegrationsScreen extends StatelessWidget {
  const PaymentsInfrastructureIntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Payments Infrastructure',
      activeIndex: 6, // Settings
      child: const _PaymentsInfraLayout(),
    );
  }
}

class _PaymentsInfraLayout extends StatelessWidget {
  const _PaymentsInfraLayout();

  @override
  Widget build(BuildContext context) {
    const divider = Color(0xFF3E3144);
    const titleColor = Colors.white;
    const muted = Color(0xFF9EA3AE);

    final cards = <_IntegrationCardModel>[
      const _IntegrationCardModel(
        title: 'stripe',
        subtitle: 'Connected',
        meta: 'Next Payout: \$1,267.25 scheduled for Apr 25',
        status: _Status.connected,
        size: _CardSize.large,
        buttonLabel: 'Connected',
      ),
      const _IntegrationCardModel(
        title: 'Plaid',
        subtitle: 'Plaid',
        meta: '',
        status: _Status.notConnected,
        size: _CardSize.medium,
        buttonLabel: 'Connect',
      ),
      const _IntegrationCardModel(
        title: 'zapier',
        subtitle: 'zapier',
        meta: '',
        status: _Status.notConnected,
        size: _CardSize.medium,
        buttonLabel: 'Connect',
      ),
      const _IntegrationCardModel(
        title: 'Webhooks/API',
        subtitle: 'Configured',
        meta: '',
        status: _Status.configured,
        size: _CardSize.smallWide,
        buttonLabel: '',
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
                'Payments & Infrastructure Integrations',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Connect your payments and automation platforms.',
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
                    // Fixed desktop-ish layout like the mock:
                    // Row 1: [Stripe (large)] [Plaid] [Zapier]
                    // Row 2: centered [Webhooks/API] beneath Plaid+Zapier area
                    if (c.maxWidth < 900) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            for (final card in cards) ...[
                              SizedBox(
                                height: 260,
                                width: double.infinity,
                                child: _IntegrationCard(model: card),
                              ),
                              const SizedBox(height: 18),
                            ],
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: _IntegrationCard(model: cards[0]),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                flex: 3,
                                child: _IntegrationCard(model: cards[1]),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                flex: 3,
                                child: _IntegrationCard(model: cards[2]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Spacer(flex: 5),
                              Expanded(
                                flex: 6,
                                child: _IntegrationCard(model: cards[3]),
                              ),
                              const Spacer(flex: 5),
                            ],
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

enum _Status { connected, notConnected, configured }

enum _CardSize { large, medium, smallWide }

class _IntegrationCardModel {
  final String title;
  final String subtitle;
  final String meta;
  final _Status status;
  final _CardSize size;
  final String buttonLabel;

  const _IntegrationCardModel({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.status,
    required this.size,
    required this.buttonLabel,
  });
}

class _IntegrationCard extends StatelessWidget {
  final _IntegrationCardModel model;
  const _IntegrationCard({required this.model});

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFF3E3144);
    const cardBg = Color(0xFF1E1E1E);
    const muted = Color(0xFF9EA3AE);
    const accent = Color(0xFFCE9799);
    const ok = Color(0xFF35C86B);

    final isStripe = model.title.toLowerCase() == 'stripe';
    final isConnected = model.status == _Status.connected;
    final isConfigured = model.status == _Status.configured;

    double height;
    switch (model.size) {
      case _CardSize.large:
        height = 260;
        break;
      case _CardSize.medium:
        height = 260;
        break;
      case _CardSize.smallWide:
        height = 200;
        break;
    }

    return Container(
      height: height,
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
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // "Logo" placeholder
          if (isStripe)
            const Text(
              'stripe',
              style: TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            )
          else
            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Icon(
                isConfigured
                    ? Icons.hub_outlined
                    : (model.title.toLowerCase() == 'plaid'
                          ? Icons.grid_4x4_outlined
                          : Icons.auto_awesome_outlined),
                color: Colors.white,
                size: 30,
              ),
            ),
          const SizedBox(height: 14),
          if (!isStripe)
            Text(
              model.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 10),

          // Status line
          if (isConnected || isConfigured)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 16, color: ok),
                const SizedBox(width: 6),
                Text(
                  isConfigured ? 'Configured' : 'Connected',
                  style: const TextStyle(
                    color: ok,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          else
            Text(
              model.subtitle,
              style: const TextStyle(
                color: muted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

          if (model.meta.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              model.meta,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 18),

          if (model.buttonLabel.trim().isNotEmpty)
            SizedBox(
              height: 36,
              width: 160,
              child: isConnected
                  ? OutlinedButton(
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
                        children: const [
                          Icon(Icons.check, size: 16, color: ok),
                          SizedBox(width: 8),
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
                    )
                  : OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accent.withValues(alpha: 0.65)),
                        backgroundColor: Colors.white.withValues(alpha: 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Connect',
                        style: TextStyle(
                          color:
                              Colors.white, // Standard white text for buttons
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
