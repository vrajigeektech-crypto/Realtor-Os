import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'agent_detail_host_screen.dart';
import '../utils/app_styles.dart';

class AgentSecurityScreen extends StatelessWidget {
  const AgentSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AgentDetailHostScreen(initialTabIndex: 7);
  }
}

class AgentSecurityContent extends StatefulWidget {
  const AgentSecurityContent({super.key});

  @override
  State<AgentSecurityContent> createState() => _AgentSecurityContentState();
}

class _AgentSecurityContentState extends State<AgentSecurityContent> {
  bool _isResetting = false;
  String _suspensionStatus = 'Active';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final horizontalPadding = isMobile ? 16.0 : 48.0;

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 32,
          ),
          children: [
            _buildSecurityActions()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.05, end: 0),
            const SizedBox(height: 48),
            _buildTableSection('Login History', [
                  {
                    'Timestamp': '04/23/2024 10:15 AM',
                    'Result': 'Success',
                    'Location': 'Los Angeles, CA',
                    'IP Address': '192.168.1.45',
                    'Auth Method': 'Password',
                  },
                  {
                    'Timestamp': '04/22/2024 08:42 PM',
                    'Result': 'Failed',
                    'Location': 'Miami, FL',
                    'IP Address': '203.87.56.102',
                    'Auth Method': 'Invalid Code',
                  },
                  {
                    'Timestamp': '04/21/2024 02:31 PM',
                    'Result': 'Success',
                    'Location': 'Las Vegas, NV',
                    'IP Address': '56.102.75.196',
                    'Auth Method': 'Password',
                  },
                  {
                    'Timestamp': '04/20/2024 09:10 AM',
                    'Result': 'Success',
                    'Location': 'Phoenix, AZ',
                    'IP Address': '198.45.67.230',
                    'Auth Method': 'Password',
                  },
                  {
                    'Timestamp': '04/19/2024 03:25 PM',
                    'Result': 'Success',
                    'Location': 'Dallas, TX',
                    'IP Address': '145.98.34.112',
                    'Auth Method': 'Password',
                  },
                ])
                .animate()
                .fadeIn(duration: 400.ms, delay: 150.ms)
                .slideY(begin: 0.05, end: 0),
            const SizedBox(height: 48),
            _buildTableSection('IP History', [
                  {
                    'IP Address': '192.168.1.45',
                    'First Seen': '04/15/2024 10:32 AM',
                    'Last Seen': '04/23/2024 10:15 AM',
                    'Risk': '',
                  },
                  {
                    'IP Address': '203.87.56.102',
                    'First Seen': '04/22/2024 08:41 PM',
                    'Last Seen': '04/22/2024 08:42 PM',
                    'Risk': 'High Risk',
                  },
                  {
                    'IP Address': '56.102.75.196',
                    'First Seen': '03/18/2024 04:55 PM',
                    'Last Seen': '04/21/2024 02:31 PM',
                    'Risk': '',
                  },
                  {
                    'IP Address': '198.45.67.230',
                    'First Seen': '02/06/2024 07:48 AM',
                    'Last Seen': '04/30/2024 09:10 AM',
                    'Risk': '',
                  },
                ])
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(begin: 0.05, end: 0),
            const SizedBox(height: 48),
            _buildTableSection('Devices', [
                  {
                    'Device': 'Desktop',
                    'OS / Browser': 'Windows 10 / Chrome',
                    'Last Active': 'Today, 10:15 AM',
                    'Status': 'Trusted',
                  },
                  {
                    'Device': 'Mobile',
                    'OS / Browser': 'iOS / Satari',
                    'Last Active': 'Yesterday, 08:42 PM',
                    'Status': 'Unrecognized',
                  },
                  {
                    'Device': 'Desktop',
                    'OS / Browser': 'MacOS / Firefox',
                    'Last Active': 'Apr 19, 2024, 05:28 PM',
                    'Status': 'Trusted',
                  },
                ])
                .animate()
                .fadeIn(duration: 400.ms, delay: 450.ms)
                .slideY(begin: 0.05, end: 0),
          ],
        );
      },
    );
  }

  Widget _buildSecurityActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Security Actions',
          style: TextStyle(
            color: AppStyles.copperBrush,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: AppStyles.premiumCardDecoration(
            color: Colors.black.withValues(alpha: 0.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _FidelityActionButton(
                    label: 'Reset Password',
                    onTap: () => setState(() => _isResetting = !_isResetting),
                  ),
                  if (_isResetting) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Confirm Reset Password?',
                            style: TextStyle(
                              color: AppStyles.mutedText,
                              fontSize: 13,
                            ),
                          ),
                          _FidelityActionButton(
                            label: 'Confirm',
                            color: AppStyles.copperBrush.withValues(alpha: 0.2),
                            onTap: () {},
                          ),
                          _FidelityActionButton(
                            label: 'Cancel',
                            onTap: () => setState(() => _isResetting = false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _FidelityActionButton(
                label: 'Force Logout from All Sessions',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Account Suspension',
                    style: TextStyle(color: AppStyles.mutedText, fontSize: 13),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ToggleItem(
                          'Active',
                          isActive: _suspensionStatus == 'Active',
                          onTap: () =>
                              setState(() => _suspensionStatus = 'Active'),
                        ),
                        _ToggleItem(
                          'Suspended',
                          isActive: _suspensionStatus == 'Suspended',
                          onTap: () =>
                              setState(() => _suspensionStatus = 'Suspended'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableSection(String title, List<Map<String, String>> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    final columns = data.first.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppStyles.copperBrush,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            constraints: const BoxConstraints(minWidth: 800),
            decoration: AppStyles.premiumCardDecoration(
              color: Colors.black.withValues(alpha: 0.2),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: columns
                        .map(
                          (col) => Expanded(
                            child: Text(
                              col.toUpperCase(),
                              style: const TextStyle(
                                color: AppStyles.mutedText,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Divider(height: 1, color: Colors.white10),
                ...data.map(
                  (row) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          children: columns.map((col) {
                            final val = row[col]!;
                            Color textColor = Colors.white.withValues(
                              alpha: 0.9,
                            );
                            if (val == 'Success') {
                              textColor = AppStyles.statusGreen;
                            }
                            if (val == 'Failed') {
                              textColor = const Color(0xFFC05A5A);
                            }
                            if (val == 'High Risk' || val == 'Unrecognized') {
                              textColor = const Color(0xFFC05A5A);
                            }

                            return Expanded(
                              child: Text(
                                val,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const Divider(height: 1, color: Colors.white10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FidelityActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _FidelityActionButton({
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color ?? Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _ToggleItem(this.label, {required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppStyles.accentRose.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppStyles.mutedText,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
