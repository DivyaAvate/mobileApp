import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/dashboard_provider.dart';
import '../../data/models/dashboard_model.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: dashAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHeader(data),
              const SizedBox(height: 25),
              _buildGridStats(data),
              const SizedBox(height: 25),
              _buildTodayWorkout(data),
              const SizedBox(height: 25),
              _buildActivityChart(data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DashboardModel data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Hello, ${data.userName}!", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Ready for your workout?", style: TextStyle(color: Colors.grey)),
        ]),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
          child: Row(children: [
            const Icon(Icons.local_fire_department, color: Colors.orange),
            Text(" ${data.streak}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ]),
        )
      ],
    );
  }

  Widget _buildGridStats(DashboardModel data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _statCard("Steps", data.steps.toString(), Icons.directions_walk, Colors.blue),
        _statCard("Recovery", "${data.recoveryScore}%", Icons.bedtime, Colors.purple),
      ],
    );
  }

  Widget _statCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTodayWorkout(DashboardModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.blue]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Today's Plan", style: TextStyle(color: Colors.white70)),
        Text(data.todayWorkoutName ?? "Rest Day", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
          child: const Text("START NOW"),
        )
      ]),
    );
  }

  Widget _buildActivityChart(DashboardModel data) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Weekly Volume (kg)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: data.activity.asMap().entries.map((e) {
                  return BarChartGroupData(x: e.key, barRods: [
                    BarChartRodData(toY: e.value.value, color: Colors.blueAccent, width: 15, borderRadius: BorderRadius.circular(4))
                  ]);
                }).toList(),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}