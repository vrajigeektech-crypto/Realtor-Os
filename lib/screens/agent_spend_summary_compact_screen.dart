import 'package:flutter/material.dart';
import 'agent_detail_host_screen.dart';
import 'widgets/spend_summary_widgets.dart';

class AgentSpendSummaryCompactScreen extends StatelessWidget {
  const AgentSpendSummaryCompactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AgentDetailHostScreen(initialTabIndex: 1);
  }
}

class AgentSpendContent extends StatefulWidget {
  const AgentSpendContent({super.key});

  @override
  State<AgentSpendContent> createState() => _AgentSpendContentState();
}

class _AgentSpendContentState extends State<AgentSpendContent> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 48,
            vertical: 32,
          ),
          children: [
            const SizedBox(height: 24),
            if (isMobile) _buildMobileStatCards() else _buildStatCardsRow(),
            const SizedBox(height: 32),
            const FidelityViewLedgerButton(),
            const SizedBox(height: 48),
            const SpendBreakdownCard(),
          ],
        );
      },
    );
  }

  Widget _buildStatCardsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If really wide, keep as row. If intermediate, use grid or wrap.
        if (constraints.maxWidth > 1000) {
          return const Row(
            children: [
              Expanded(
                child: SpendStatCard(
                  label: 'Available Balance',
                  value: '\$8,250.00',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SpendStatCard(
                  label: 'Committed Tokens',
                  value: '\$3,400.00',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SpendStatCard(
                  label: 'Spend in Queue',
                  value: '\$1,200.00',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SpendStatCard(
                  label: 'Lifetime Spend Total',
                  value: '\$67,850.00',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SpendStatCard(
                  label: 'Spend This Month',
                  value: '\$5,600.00',
                ),
              ),
            ],
          );
        } else {
          // Intermediate/Tablet: Use Wrap or Grid
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSizedBoxedCard('Available Balance', '\$8,250.00'),
              _buildSizedBoxedCard('Committed Tokens', '\$3,400.00'),
              _buildSizedBoxedCard('Spend in Queue', '\$1,200.00'),
              _buildSizedBoxedCard('Lifetime Spend Total', '\$67,850.00'),
              _buildSizedBoxedCard('Spend This Month', '\$5,600.00'),
            ],
          );
        }
      },
    );
  }

  Widget _buildSizedBoxedCard(String label, String value) {
    return SizedBox(
      width: 180,
      child: SpendStatCard(label: label, value: value),
    );
  }

  Widget _buildMobileStatCards() {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SpendStatCard(
                label: 'Spend This Month',
                value: '\$2,450.00',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: SpendStatCard(label: 'Tokens Allotted', value: '10,000'),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SpendStatCard(label: 'Tokens Used', value: '4,500'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: SpendStatCard(label: 'Remaining Tokens', value: '5,500'),
            ),
          ],
        ),
        SizedBox(height: 12),
        SpendStatCard(label: 'Next Recharge', value: '12 Days'),
      ],
    );
  }
}
