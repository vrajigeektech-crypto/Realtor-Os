import 'package:flutter/material.dart';
import '../../data/models/integration_models.dart';
import '../cards/integration_tile_card.dart';

class IntegrationsTileGrid extends StatelessWidget {
  const IntegrationsTileGrid({
    super.key,
    required this.items,
    required this.onConnect,
    required this.onDisconnect,
    required this.busyKeys,
  });

  final List<IntegrationModel> items;
  final void Function(String integrationKey) onConnect;
  final void Function(String integrationKey) onDisconnect;
  final Set<String> busyKeys;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final int columns = width >= 1200
            ? 4
            : width >= 900
                ? 3
                : width >= 600
                    ? 2
                    : 1;

        const gap = 16.0;

        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            childAspectRatio: 1.25,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isBusy = busyKeys.contains(item.integrationKey);

            return IntegrationTileCard(
              integration: item,
              onConnect: () => onConnect(item.integrationKey),
              onDisconnect: () => onDisconnect(item.integrationKey),
              isLoading: isBusy,
            );
          },
        );
      },
    );
  }
}
