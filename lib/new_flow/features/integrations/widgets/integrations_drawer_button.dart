import 'package:flutter/material.dart';
import '../screens/integrations_drawer.dart';

class IntegrationsDrawerButton extends StatelessWidget {
  const IntegrationsDrawerButton({
    super.key,
    required this.userId,
    this.onIntegrationTap,
    this.icon,
    this.label,
  });

  final String userId;
  final void Function(String integrationKey)? onIntegrationTap;
  final IconData? icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (label != null) {
      // Text button with label
      return TextButton.icon(
        onPressed: () => _openDrawer(context),
        icon: Icon(icon ?? Icons.integration_instructions),
        label: Text(label!),
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
        ),
      );
    } else {
      // Icon button only
      return IconButton(
        onPressed: () => _openDrawer(context),
        icon: Icon(icon ?? Icons.integration_instructions),
        tooltip: 'Integrations',
      );
    }
  }

  void _openDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Integrations',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, _) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: double.infinity,
                child: IntegrationsDrawer(
                  userId: userId,
                  onIntegrationTap: onIntegrationTap,
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}
