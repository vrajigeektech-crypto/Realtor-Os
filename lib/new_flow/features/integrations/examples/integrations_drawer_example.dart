import 'package:flutter/material.dart';
import '../widgets/integrations_drawer_button.dart';

/// Example of how to use the IntegrationsDrawerButton in your app
class IntegrationsDrawerExample extends StatelessWidget {
  const IntegrationsDrawerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App with Integrations'),
        actions: [
          // Icon button in app bar
          IntegrationsDrawerButton(
            userId: 'CURRENT_USER_ID', // Replace with actual user ID
            onIntegrationTap: (integrationKey) {
              // Handle integration tap
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped: $integrationKey')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Integrations Examples',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Different button styles
            const Text('Icon Button:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            IntegrationsDrawerButton(
              userId: 'CURRENT_USER_ID',
              icon: Icons.apps,
            ),
            
            const SizedBox(height: 24),
            
            // Text button with custom icon and label
            const Text('Text Button:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            IntegrationsDrawerButton(
              userId: 'CURRENT_USER_ID',
              icon: Icons.settings,
              label: 'Manage Integrations',
              onIntegrationTap: (integrationKey) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Managing: $integrationKey')),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Button in a card
            const Text('In Card:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connected Tools',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text('Manage your integrations'),
                        ],
                      ),
                    ),
                    IntegrationsDrawerButton(
                      userId: 'CURRENT_USER_ID',
                      icon: Icons.arrow_forward_ios,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
