import 'package:flutter/material.dart';
import '../controllers/integrations_all_set_controller.dart';
import '../controllers/integrations_all_set_state.dart';
import '../widgets/integration_card.dart';

// Import the existing IntegrationCard's enum to avoid conflicts
import '../widgets/integration_card.dart' as card_widget;
import '../models/integration_model.dart' as model;

class IntegrationsDrawer extends StatefulWidget {
  const IntegrationsDrawer({
    super.key,
    required this.userId,
    this.onIntegrationTap,
  });

  final String userId;
  final void Function(String integrationKey)? onIntegrationTap;

  @override
  State<IntegrationsDrawer> createState() => _IntegrationsDrawerState();
}

class _IntegrationsDrawerState extends State<IntegrationsDrawer> {
  late final IntegrationsAllSetController _controller;

  @override
  void initState() {
    super.initState();
    _controller = IntegrationsAllSetController(userId: widget.userId);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: const Color(0xFF1C1B1F),
      child: ValueListenableBuilder<IntegrationsAllSetState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6),
                      const Color(0xFF7C3AED),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.integration_instructions,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Integrations',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!state.loadingHeader && state.headerTitle != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.headerTitle!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.headerSubtitle ?? 'Connect your favorite tools',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          if (state.completionPercent != null) ...[
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: (state.completionPercent!.clamp(0, 100)) / 100,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${state.connectedCount ?? 0} of ${state.totalCount ?? 0} connected',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: state.loadingGrid
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8B5CF6),
                        ),
                      )
                    : state.error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Error: ${state.error}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.red.shade300,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.groups.length,
                            itemBuilder: (context, groupIndex) {
                              final group = state.groups[groupIndex];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Group header
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8B5CF6),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                group.title,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (group.subtitle.isNotEmpty)
                                                Text(
                                                  group.subtitle,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: Colors.white.withOpacity(0.6),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Integration cards
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1.2,
                                    ),
                                    itemCount: group.items.length,
                                    itemBuilder: (context, itemIndex) {
                                      final integration = group.items[itemIndex];
                                      return _buildIntegrationCard(
                                        integration,
                                        state.busyKeys.contains(integration.integrationKey),
                                      );
                                    },
                                  ),

                                  if (groupIndex < state.groups.length - 1)
                                    const SizedBox(height: 24),
                                ],
                              );
                            },
                          ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to full integrations screen
                          Navigator.of(context).pop();
                          // TODO: Navigate to full integrations screen
                        },
                        icon: const Icon(Icons.dashboard_outlined, size: 18),
                        label: const Text('View All'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          // Navigate to add new integration
                          Navigator.of(context).pop();
                          // TODO: Navigate to add integration screen
                        },
                        icon: const Icon(Icons.add_outlined, size: 18),
                        label: const Text('Add New'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIntegrationCard(model.IntegrationModel integration, bool isBusy) {
    // Convert IntegrationStatus from model to the existing IntegrationCard's enum
    final cardStatus = integration.status == model.IntegrationStatus.connected 
        ? card_widget.IntegrationStatus.connected 
        : card_widget.IntegrationStatus.disconnected;

    return GestureDetector(
      onTap: isBusy 
          ? null 
          : () {
              widget.onIntegrationTap?.call(integration.integrationKey);
              _controller.onTapIntegration(context, integration.integrationKey);
            },
      child: IntegrationCard(
        name: integration.displayName,
        status: cardStatus,
      ),
    );
  }
}
