import 'package:flutter/material.dart';

class SyncSuccessCard extends StatelessWidget {
  const SyncSuccessCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Leads Synced Successfully!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text('• 1,250 Contacts Imported'),
            const Text('• 5 Pipelines Analyzed'),
            const Text('• 18 Leads Flagged for Follow-Up'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Lead Dashboard
              },
              child: const Text('View Lead Dashboard'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Sync Again Later'),
            ),
          ],
        ),
      ),
    );
  }
}
