import 'package:flutter/material.dart';

class ProgressDashboardPage extends StatelessWidget {
  const ProgressDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        backgroundColor: const Color(0xFF0F1117),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Progress Tracking',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your fitness progress will appear here',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}