import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import '../utils/app_styles.dart';

class ConnectYourToolsScreen extends StatelessWidget {
  const ConnectYourToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Tools & Integrations',
      activeIndex: 9, // Example index
      child: const _ConnectToolsLayout(),
    );
  }
}

class _ConnectToolsLayout extends StatelessWidget {
  const _ConnectToolsLayout();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.fidelityBackgroundDecoration(),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 32),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppStyles.copperGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppStyles.accentRose.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.hub, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Connect Your Tools',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Link your existing platforms to centralize data and empower your AI agents.',
                      style: TextStyle(color: AppStyles.mutedText, fontSize: 16),
                    ),
                  ],
                ),
              ),
              _buildFilterButton('Category: All'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_drop_down, color: AppStyles.mutedText, size: 18),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        _buildSectionHeader('CRM & Lead Management'),
        const SizedBox(height: 24),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _buildIntegrationCard(
              title: 'Salesforce',
              description: 'Sync contacts, leads, and opportunities automatically.',
              status: 'Connected',
              iconUrl: 'https://upload.wikimedia.org/wikipedia/commons/f/f9/Salesforce.com_logo.svg',
            ),
            _buildIntegrationCard(
              title: 'HubSpot',
              description: 'Two-way sync for marketing and sales data.',
              status: 'Connect',
              iconUrl: 'https://upload.wikimedia.org/wikipedia/commons/3/3f/HubSpot_Logo.png',
            ),
            _buildIntegrationCard(
              title: 'FollowUp Boss',
              description: 'Real estate specific CRM integration for lead routing.',
              status: 'Connect',
              iconUrl: 'https://logosandtypes.com/wp-content/uploads/2021/01/follow-up-boss.svg',
              isDarkIcon: true,
            ),
          ],
        ),
        const SizedBox(height: 48),
        _buildSectionHeader('Marketing & Social Media'),
        const SizedBox(height: 24),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _buildIntegrationCard(
              title: 'Facebook Ads',
              description: 'Automate ad spend tracking and lead generation.',
              status: 'Connected',
              iconUrl: 'https://upload.wikimedia.org/wikipedia/commons/b/b8/2021_Facebook_icon.svg',
            ),
            _buildIntegrationCard(
              title: 'Mailchimp',
              description: 'Manage email campaigns and subscriber lists.',
              status: 'Connect',
              iconUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Mailchimp_freddie_icon.svg/1024px-Mailchimp_freddie_icon.svg.png',
            ),
            _buildIntegrationCard(
              title: 'Instagram',
              description: 'Schedule posts and analyze engagement metrics.',
              status: 'Connect',
              iconUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/e7/Instagram_logo_2016.svg',
            ),
          ],
        ),
        const SizedBox(height: 48),
        _buildSectionHeader('Productivity & Documents'),
        const SizedBox(height: 24),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _buildIntegrationCard(
              title: 'Google Workspace',
              description: 'Connect Gmail, Calendar, and Drive files.',
              status: 'Connected',
              iconUrl: 'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
            ),
            _buildIntegrationCard(
              title: 'DocuSign',
              description: 'Automate e-signatures and contract tracking.',
              status: 'Connect',
              iconUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/DocuSign_logo.svg/1024px-DocuSign_logo.svg.png',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppStyles.copperBrush,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildIntegrationCard({
    required String title,
    required String description,
    required String status,
    required String iconUrl,
    bool isDarkIcon = false,
  }) {
    final isConnected = status == 'Connected';

    return Container(
      width: 380,
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.premiumCardDecoration(
        color: Colors.black.withValues(alpha: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkIcon ? Colors.white : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Image.network(
                  iconUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.extension, color: Colors.white54),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppStyles.statusGreen.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isConnected
                        ? AppStyles.statusGreen.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isConnected) ...[
                      const Icon(Icons.check_circle, color: AppStyles.statusGreen, size: 14),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      status,
                      style: TextStyle(
                        color: isConnected ? AppStyles.statusGreen : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
            description,
            style: const TextStyle(
              color: AppStyles.mutedText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          if (isConnected)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Configure'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFC05A5A)),
                      foregroundColor: const Color(0xFFC05A5A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Disconnect'),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Connect Integration'),
              ),
            ),
        ],
      ),
    );
  }
}
