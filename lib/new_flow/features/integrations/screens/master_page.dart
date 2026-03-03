import 'package:flutter/material.dart';
import '../widgets/integrations_grid.dart';
import '../widgets/integration_section_header.dart';

class MasterPageScreen extends StatelessWidget {
  const MasterPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MasterPage - Connect Tools'),
        backgroundColor: const Color(0xFF1C1B1F),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IntegrationSectionHeader(
                title: 'Connect Your Tools',
                subtitle:
                    'Link your accounts to unlock automations and tracking.',
              ),
              const SizedBox(height: 24),
              const Expanded(
                child: IntegrationsGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
