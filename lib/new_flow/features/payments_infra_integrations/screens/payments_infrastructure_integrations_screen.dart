import 'package:flutter/material.dart';
import '../controllers/payments_infra_integrations_controller.dart';
import '../widgets/grids/integrations_tile_grid.dart';
import '../widgets/headers/integrations_page_header.dart';

class PaymentsInfrastructureIntegrationsScreen extends StatefulWidget {
  const PaymentsInfrastructureIntegrationsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentsInfrastructureIntegrationsScreen> createState() =>
      _PaymentsInfrastructureIntegrationsScreenState();
}

class _PaymentsInfrastructureIntegrationsScreenState
    extends State<PaymentsInfrastructureIntegrationsScreen> {
  late final PaymentsInfraIntegrationsController controller;

  @override
  void initState() {
    super.initState();
    controller = PaymentsInfraIntegrationsController();
    // TODO: Get actual user ID
    controller.loadIntegrations('user_123');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntegrationsPageHeader(
                title: 'Payments & Infrastructure Integrations',
                subtitle: 'Connect your payments and automation platforms.',
                onRefresh: () => controller.loadIntegrations('user_123'),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: controller.state,
                  builder: (context, state, child) {
                    if (state.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state.errorMessage != null) {
                      return Center(
                        child: Text(
                          'Error: ${state.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    return IntegrationsTileGrid(
                      items: state.items,
                      onConnect: (integrationKey) =>
                          controller.connect('user_123', integrationKey),
                      onDisconnect: (integrationKey) =>
                          controller.disconnect('user_123', integrationKey),
                      busyKeys: state.busyKeys,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
