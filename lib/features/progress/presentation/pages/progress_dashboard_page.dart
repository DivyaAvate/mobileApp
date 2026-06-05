import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/progress_provider.dart';

class ProgressDashboardPage extends ConsumerWidget {
  const ProgressDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: const Text('Progress',
          style: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMuted),
            onPressed: () => ref.invalidate(progressProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border)),
      ),
      body: progressAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text('$e',
                style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(progressProvider),
                child: const Text('Retry'),
              ),
            ],
          )),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Summary Stats ──────────────────────────────
              _buildSummaryRow(data),
              const SizedBox(height: 20),

              // ── Volume Chart ───────────────────────────────
              _buildSectionTitle('Weekly Volume'),
              const SizedBox(height: 10),
              _buildVolumeChart(data),
              const SizedBox(height: 20),

              // ── Strength PRs ───────────────────────────────
              _buildSectionTitle('Personal Records'),
              const SizedBox(height: 10),
              _buildPRList(data),
              const SizedBox(height: 20),

              // ── Body Weight ────────────────────────────────
              if (data.weightHistory.isNotEmpty) ...[
                _buildSectionTitle('Body Weight'),
                const SizedBox(height: 10),
                _buildWeightChart(data),
                const SizedBox(height: 20),
              ],

              // ── Workout History ────────────────────────────
              _buildSectionTitle('Recent Workouts'),
              const SizedBox(height: 10),
              _buildWorkoutHistory(data),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Title ─────────────────────────────────────────

  Widget _buildSectionTitle(String title) => Text(title,
    style: const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 15, fontWeight: FontWeight.w600));

  // ── Summary Row ───────────────────────────────────────────

  Widget _buildSummaryRow(ProgressData data) {
    return Row(children: [
      _MiniStat(
        label: 'Total Workouts',
        value: '${data.totalWorkouts}',
        color: AppColors.accentGreen,
      ),
      const SizedBox(width: 10),
      _MiniStat(
        label: 'Total Volume',
        value: '${(data.totalVolume / 1000).toStringAsFixed(1)}t',
        color: AppColors.accentBlue,
      ),
      const SizedBox(width: 10),
      _MiniStat(
        label: 'This Week',
        value: '${data.weeklyWorkouts}',
        color: AppColors.accentOrange,
      ),
    ]);
  }

  // ── Volume Chart ──────────────────────────────────────────

  Widget _buildVolumeChart(ProgressData data) {
    if (data.weeklyVolume.isEmpty) {
      return _EmptyCard(message: 'No workout data yet');
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: BarChart(
        BarChartData(
          barGroups: data.weeklyVolume.asMap().entries.map((e) =>
            BarChartGroupData(x: e.key, barRods: [
              BarChartRodData(
                toY:          e.value.volume.toDouble(),
                color:        AppColors.accentGreen,
                width:        18,
                borderRadius: BorderRadius.circular(4),
              ),
            ]),
          ).toList(),
          borderData:  FlBorderData(show: false),
          gridData:    const FlGridData(show: false),
          titlesData:  FlTitlesData(
            leftTitles:   const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
            rightTitles:  const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
            topTitles:    const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) {
                  final i = val.toInt();
                  if (i < 0 || i >= data.weeklyVolume.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(data.weeklyVolume[i].label,
                      style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 10)),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── PR List ───────────────────────────────────────────────

  Widget _buildPRList(ProgressData data) {
    if (data.personalRecords.isEmpty) {
      return _EmptyCard(message: 'No PRs yet — keep lifting!');
    }
    return Column(
      children: data.personalRecords.map((pr) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          const Icon(Icons.emoji_events,
            color: AppColors.accentOrange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(pr.exerciseName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Text('${pr.weightKg} kg × ${pr.reps}',
            style: const TextStyle(
              color: AppColors.accentGreen,
              fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      )).toList(),
    );
  }

  // ── Weight Chart ──────────────────────────────────────────

  Widget _buildWeightChart(ProgressData data) {
    final spots = data.weightHistory.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.weight))
        .toList();

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: LineChart(
        LineChartData(
          gridData:   const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles:   const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
            rightTitles:  const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
            topTitles:    const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots:        spots,
              isCurved:     true,
              color:        AppColors.accentBlue,
              barWidth:     2,
              dotData:      const FlDotData(show: false),
              belowBarData: BarAreaData(
                show:  true,
                color: AppColors.accentBlue.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Workout History ───────────────────────────────────────

  Widget _buildWorkoutHistory(ProgressData data) {
    if (data.recentWorkouts.isEmpty) {
      return _EmptyCard(message: 'No workouts logged yet');
    }
    return Column(
      children: data.recentWorkouts.map((w) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fitness_center,
              color: AppColors.accentGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(w.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13, fontWeight: FontWeight.w500)),
              Text('${w.totalSets} sets · ${w.totalVolume} kg · ${w.durationMin} min',
                style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11)),
            ],
          )),
          Text(w.dateLabel,
            style: const TextStyle(
              color: AppColors.textMuted, fontSize: 11)),
        ]),
      )).toList(),
    );
  }
}

// ─── Mini Stat ────────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: [
        Text(value,
          style: TextStyle(
            color: color, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textMuted, fontSize: 10)),
      ]),
    ),
  );
}

// ─── Empty Card ───────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border, width: 0.5),
    ),
    child: Text(message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
  );
}