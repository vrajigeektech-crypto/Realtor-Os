import 'package:flutter/material.dart';
import 'package:demo/admin_pannel/admin_login_screen.dart';
import 'package:demo/main.dart';

void main() {
  runApp(const TestAdminLoginApp());
}

class TestAdminLoginApp extends StatelessWidget {
  const TestAdminLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Login Test',
      theme: ThemeData.dark(),
      home: const AdminLoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
