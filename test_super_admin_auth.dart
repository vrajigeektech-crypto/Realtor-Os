import 'package:flutter/material.dart';
import 'package:demo/admin_pannel/admin_login_screen.dart';

void main() {
  runApp(const TestSuperAdminAuthApp());
}

class TestSuperAdminAuthApp extends StatelessWidget {
  const TestSuperAdminAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Admin Auth Test',
      theme: ThemeData.dark(),
      home: const TestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Authentication Test'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('1. Select "Super Admin" from the dropdown'),
            Text('2. Enter email: admin@gmail.com'),
            Text('3. Enter password: 111111'),
            Text('4. Click Login'),
            SizedBox(height: 16),
            Text(
              'Expected Result:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('✅ Should authenticate successfully'),
            Text('✅ Should navigate to AdminMainScreen'),
            Text('✅ User metadata should include Super Admin role'),
            SizedBox(height: 16),
            Text(
              'Negative Test:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('❌ Any other email/password should fail'),
            Text('❌ Any other role should not trigger Super Admin logic'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
          );
        },
        child: const Icon(Icons.login),
      ),
    );
  }
}
