import 'package:flutter/material.dart';

// Layout
import '../layout/main_layout.dart';

// Screens
import 'agent_detail_profile_screen.dart';
import 'agent_security_screen.dart';
import 'agent_spend_summary_compact_screen.dart';
import 'agent_tasks_queue_screen.dart';
import 'automation_queue_screen_new.dart';
import 'checkout_confirmation_ready_screen.dart';
import 'complete_purchase_screen.dart'; // New
import 'connect_your_tools_screen.dart';
import 'content_approval_queue_screen.dart';
import 'embedded_checkout_screen.dart';
import 'google_integrations_screen.dart';
import 'integrations_screen.dart';
import 'order_management_screen.dart';
import 'payments_infrastructure_integrations_screen.dart'; // New
import 'purchase_tokens_screen.dart'; // New
import 'secure_trusted_checkout_screen.dart';
import 'sla_time_control_panel_screen.dart';
import 'task_audit_log_screen.dart'; // New
import 'task_queue_screen.dart'; // New
import 'tiktok_listing_walkthrough_screen.dart'; // New
import 'upload_for_client_review_screen.dart'; // New
import 'user_agent_management_screen.dart'; // New

class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Dev Screen Menu',
      activeIndex: 0, // Dashboard
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Development Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select a screen to view its implementation.',
                  style: TextStyle(color: Color(0xFF9EA3AE), fontSize: 16),
                ),
                const SizedBox(height: 32),

                // Group 1: Core / Profile
                _SectionTitle('Core & Profile'),
                _MenuButton(
                  'Agent Detail Profile',
                  (ctx) => const AgentDetailProfileScreen(),
                ),
                _MenuButton(
                  'Agent Security',
                  (ctx) => const AgentSecurityScreen(),
                ),
                _MenuButton(
                  'Connect Your Tools',
                  (ctx) => const ConnectYourToolsScreen(),
                ),
                _MenuButton(
                  'User Agent Management', // New
                  (ctx) => const UserAgentManagementScreen(),
                ),

                const SizedBox(height: 24),

                // Group 2: Tasks & Queues
                _SectionTitle('Tasks & Workflows'),
                _MenuButton(
                  'Agent Tasks Queue',
                  (ctx) => const AgentTasksQueueScreen(),
                ),
                _MenuButton(
                  'Task Queue (Alternative)', // New
                  (ctx) => const TaskQueueScreen(),
                ),
                _MenuButton(
                  'Automation Queue',
                  (ctx) => const AutomationQueueScreen(),
                ),
                _MenuButton(
                  'Content Approval Queue',
                  (ctx) => const ContentApprovalQueueScreen(),
                ),
                _MenuButton(
                  'SLA Time Control',
                  (ctx) => const SlaTimeControlPanelScreen(),
                ),
                _MenuButton(
                  'Task Audit Log', // New
                  (ctx) => const TaskAuditLogScreen(),
                ),
                _MenuButton(
                  'Upload for Client Review', // New
                  (ctx) => const UploadForClientReviewScreen(),
                ),
                _MenuButton(
                  'TikTok Listing Walkthrough', // New
                  (ctx) => const TikTokListingWalkthroughScreen(),
                ),

                const SizedBox(height: 24),

                // Group 3: Financials & Checkout
                _SectionTitle('Financial & Checkout'),
                _MenuButton(
                  'Agent Spend Summary',
                  (ctx) => const AgentSpendSummaryCompactScreen(),
                ),
                _MenuButton(
                  'Order Management',
                  (ctx) => const OrderManagementScreen(),
                ),
                _MenuButton(
                  'Secure Trusted Checkout',
                  (ctx) => const SecureTrustedCheckoutScreen(),
                ),
                _MenuButton(
                  'Embedded Checkout',
                  (ctx) => const EmbeddedCheckoutScreen(),
                ),
                _MenuButton(
                  'Checkout Confirmation',
                  (ctx) => const CheckoutConfirmationReadyScreen(),
                ),
                _MenuButton(
                  'Complete Purchase', // New
                  (ctx) => const CompletePurchaseScreen(),
                ),
                _MenuButton(
                  'Purchase Tokens', // New
                  (ctx) => const PurchaseTokensScreen(),
                ),

                const SizedBox(height: 24),

                // Group 4: Integrations
                _SectionTitle('Integrations'),
                _MenuButton(
                  'Integrations Dashboard',
                  (ctx) => const IntegrationsScreen(),
                ),
                _MenuButton(
                  'Google Integrations',
                  (ctx) => const GoogleIntegrationsScreen(),
                ),
                _MenuButton(
                  'Payments Infrastructure', // New
                  (ctx) => const PaymentsInfrastructureIntegrationsScreen(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFCE9799), // Rose Gold
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final WidgetBuilder builder;

  const _MenuButton(this.label, this.builder);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: builder));
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF3E3144)),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward,
                color: Color(0xFF9EA3AE),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
