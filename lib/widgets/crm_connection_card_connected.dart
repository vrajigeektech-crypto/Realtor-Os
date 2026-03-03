import 'package:flutter/material.dart';

class CrmConnectionCardConnected extends StatelessWidget {
  const CrmConnectionCardConnected({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GoHighLevel Connected',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Location ID: LOC12345 • Connected today'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
