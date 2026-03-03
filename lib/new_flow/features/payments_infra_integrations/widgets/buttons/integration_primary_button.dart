import 'package:flutter/material.dart';

class IntegrationPrimaryButton extends StatelessWidget {
  const IntegrationPrimaryButton({
    super.key,
    required this.connected,
    required this.onConnect,
    required this.onDisconnect,
    this.isLoading = false,
  });

  final bool connected;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: FilledButton(
        onPressed: connected ? onDisconnect : onConnect,
        child: Text(connected ? 'Disconnect' : 'Connect'),
      ),
    );
  }
}
