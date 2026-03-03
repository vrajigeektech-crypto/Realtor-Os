import 'package:flutter/material.dart';

class IntegrationConnectButton extends StatelessWidget {
  final bool connected;
  final bool loading;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const IntegrationConnectButton({
    super.key,
    required this.connected,
    required this.loading,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: connected ? onDisconnect : onConnect,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              connected ? Colors.grey.shade700 : Colors.blueAccent,
        ),
        child: Text(connected ? 'Disconnect' : 'Connect'),
      ),
    );
  }
}
