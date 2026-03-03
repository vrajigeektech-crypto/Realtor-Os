import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          'CRM Connected',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Your GoHighLevel account is connected.\nNext, we\'ll pull your leads and analyze their real status.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
