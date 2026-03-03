import 'package:flutter/material.dart';
import '../screens/google_integrations_drawer.dart';

class GoogleIntegrationRoutes {
  static const String googleIntegrationsDrawer = '/integrations/google/drawer';

  static Map<String, WidgetBuilder> routes = {
    googleIntegrationsDrawer: (context) => const GoogleIntegrationsDrawer(),
  };

  static void showGoogleIntegrationsDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D0F),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const GoogleIntegrationsDrawer(),
      ),
    );
  }

  static void navigateToGoogleIntegrationsDrawer(BuildContext context) {
    Navigator.of(context).pushNamed(googleIntegrationsDrawer);
  }
}
