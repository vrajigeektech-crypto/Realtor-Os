import 'package:flutter/material.dart';
import '../widgets/google_integrations_grid.dart';
import '../widgets/google_integrations_header.dart';
import '../controllers/google_integrations_controller.dart';

class GoogleIntegrationsDrawer extends StatefulWidget {
  const GoogleIntegrationsDrawer({super.key});

  @override
  State<GoogleIntegrationsDrawer> createState() => _GoogleIntegrationsDrawerState();
}

class _GoogleIntegrationsDrawerState extends State<GoogleIntegrationsDrawer> {
  late final GoogleIntegrationsController controller;

  @override
  void initState() {
    super.initState();
    controller = GoogleIntegrationsController();
    controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const GoogleIntegrationsHeader(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 24),
          // Grid content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GoogleIntegrationsGrid(
                controller: controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
