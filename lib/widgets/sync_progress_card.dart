import 'package:flutter/material.dart';

class SyncProgressCard extends StatelessWidget {
  const SyncProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 12),
                Text(
                  'Pulling your leads',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            _ProgressItem('Fetching contacts'),
            _ProgressItem('Mapping pipelines & stages'),
            _ProgressItem('Analyzing activity & ownership'),
            _ProgressItem('Preparing lead intelligence'),
          ],
        ),
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String label;

  const _ProgressItem(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
