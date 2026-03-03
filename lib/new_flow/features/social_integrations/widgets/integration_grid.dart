import 'package:flutter/material.dart';
import '../controllers/social_media_integrations_state.dart';
import 'integration_card.dart';

class IntegrationGrid extends StatelessWidget {
  const IntegrationGrid({
    super.key,
    required this.isWide,
    required this.items,
    required this.busyKeys,
    required this.onConnect,
    required this.onDisconnect,
  });

  final bool isWide;
  final List<SocialIntegrationItem> items;
  final Set<String> busyKeys;
  final Future<void> Function(String integrationKey) onConnect;
  final Future<void> Function(String integrationKey) onDisconnect;

  @override
  Widget build(BuildContext context) {
    final columns = isWide ? 4 : 2;
    const gap = 16.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: gap,
        mainAxisSpacing: gap,
        childAspectRatio: 1.25,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final busy = busyKeys.contains(item.integrationKey);

        return IntegrationCard(
          item: item,
          busy: busy,
          onConnect: () => onConnect(item.integrationKey),
          onDisconnect: () => onDisconnect(item.integrationKey),
        );
      },
    );
  }
}
