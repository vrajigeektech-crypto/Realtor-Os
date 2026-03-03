import 'package:flutter/material.dart';
import 'writing_sample_card.widget.dart';

class WritingSamplesScreen extends StatelessWidget {
  const WritingSamplesScreen({
    super.key,
    required this.onUploadExamples,
  });

  final VoidCallback onUploadExamples;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D. Writing Samples'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: WritingSampleCard(
            title: 'Your Writing Samples',
            description:
                'Upload past newsletters or emails so we can match your language and tone.',
            ctaLabel: 'Upload Examples',
            onCtaPressed: onUploadExamples,
          ),
        ),
      ),
    );
  }
}
