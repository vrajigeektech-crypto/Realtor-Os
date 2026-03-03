import 'package:flutter/material.dart';

class IntegrationConnectButton extends StatelessWidget {
  const IntegrationConnectButton({
    super.key,
    required this.connected,
    required this.busy,
    required this.onConnect,
    required this.onDisconnect,
  });

  final bool connected;
  final bool busy;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
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
