import 'package:flutter/material.dart';

class RecoveryDashboardPage extends StatelessWidget {
  const RecoveryDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: const Text('Recovery Dashboard'),
        backgroundColor: const Color(0xFF0F1117),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bedtime, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Recovery Tracking',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Sleep, rest & recovery metrics here',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}