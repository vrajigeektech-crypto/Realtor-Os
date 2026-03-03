import 'package:flutter/material.dart';

class SyncLeadsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SyncLeadsButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text('Sync Leads'),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'This may take a few minutes depending on the size of your database.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
