import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/steps_provider.dart';

class StepsScreen extends ConsumerWidget {
  const StepsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepsAsync = ref.watch(stepsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Step Tracker")),
      body: RefreshIndicator(
        onRefresh: () => ref.read(stepsProvider.notifier).fetchAndSyncSteps(),
        child: stepsAsync.when(
          data: (stepsState) {
            final todaySteps = stepsState.todaySteps;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildCircleProgress(todaySteps),
                  const SizedBox(height: 30),
                  _buildStatRow(todaySteps),
                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Last 7 Days", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                  ),
                  _buildTrendsList(stepsState.trends),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }

  Widget _buildCircleProgress(int steps) {
    double progress = steps / 10000; // Goal: 10k steps
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200, height: 200,
          child: CircularProgressIndicator(
            value: progress > 1 ? 1 : progress,
            strokeWidth: 15,
            backgroundColor: Colors.grey[200],
            color: Colors.greenAccent,
          ),
        ),
        Column(children: [
          Text(steps.toString(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
          const Text("STEPS", style: TextStyle(color: Colors.grey)),
        ])
      ],
    );
  }

  Widget _buildStatRow(int steps) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _miniStat("Calories", "${(steps * 0.04).toStringAsFixed(0)} kcal", Icons.local_fire_department, Colors.orange),
        _miniStat("Distance", "${(steps * 0.0008).toStringAsFixed(2)} km", Icons.location_on, Colors.blue),
      ],
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Column(children: [
      Icon(icon, color: color),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ]);
  }

  Widget _buildTrendsList(List trends) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trends.length,
      itemBuilder: (context, i) {
        final day = trends[i];
        return ListTile(
          title: Text("${day.date.day}/${day.date.month}"),
          trailing: Text("${day.steps} steps", style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}