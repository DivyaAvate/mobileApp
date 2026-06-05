import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/dashboard_provider.dart';
import '../../data/models/dashboard_model.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: dashAsync.when(
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
                onPressed: () => ref.invalidate(dashboardProvider),
                child: const Text('Retry'),
              ),
            ],
          )),
        data: (data) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildHeader(context, data),
                const SizedBox(height: 20),
                _buildStatsGrid(data),
                const SizedBox(height: 20),
                _buildTodayWorkout(context, data),
                const SizedBox(height: 20),
                _buildActivityChart(data),
                const SizedBox(height: 20),
                _buildQuickLinks(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, DashboardModel data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hello, ${data.userName}! 👋',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20, fontWeight: FontWeight.w600)),
          const Text('Ready for your workout?',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accentOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accentOrange.withValues(alpha: 0.3),
              width: 0.5),
          ),
          child: Row(children: [
            const Icon(Icons.local_fire_department,
              color: AppColors.accentOrange, size: 18),
            const SizedBox(width: 4),
            Text('${data.streak}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700, fontSize: 16)),
          ]),
        ),
      ],
    );
  }

  // ── Stats Grid ────────────────────────────────────────────

  Widget _buildStatsGrid(DashboardModel data) {
    return Row(children: [
      _StatCard(label: 'Steps',     value: '${data.steps}',
        icon: Icons.directions_walk, color: AppColors.accentBlue),
      const SizedBox(width: 10),
      _StatCard(label: 'Recovery',  value: '${data.recoveryScore}%',
        icon: Icons.bedtime_outlined, color: AppColors.accentGreen),
      const SizedBox(width: 10),
      _StatCard(label: 'Workouts',  value: '${data.totalWorkouts}',
        icon: Icons.fitness_center, color: AppColors.accentOrange),
    ]);
  }

  // ── Today's Workout ───────────────────────────────────────

  Widget _buildTodayWorkout(BuildContext context, DashboardModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.accentBlue.withValues(alpha: 0.15),
          AppColors.accentGreen.withValues(alpha: 0.1),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentBlue.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("TODAY'S PLAN",
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text(data.todayWorkoutName ?? 'Rest Day',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        if (data.todayWorkoutName != null)
          ElevatedButton(
            onPressed: () => context.push('/active-workout'),
            child: const Text('Start Now'),
          ),
      ]),
    );
  }

  // ── Activity Chart ────────────────────────────────────────

  Widget _buildActivityChart(DashboardModel data) {
    if (data.activity.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Volume (kg)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: data.activity.asMap().entries.map((e) =>
                  BarChartGroupData(x: e.key, barRods: [
                    BarChartRodData(
                      toY:          e.value.value,
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
                        if (i < 0 || i >= data.activity.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(data.activity[i].label,
                          style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 10));
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Links ───────────────────────────────────────────

  Widget _buildQuickLinks(BuildContext context) {
    return Row(children: [
      _QuickLink(label: 'Achievements', icon: Icons.emoji_events,
        onTap: () => context.push('/achievements')),
      const SizedBox(width: 10),
      _QuickLink(label: 'Leaderboard', icon: Icons.leaderboard,
        onTap: () => context.push('/leaderboard')),
    ]);
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value,
    required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value,
          style: TextStyle(
            color: color, fontSize: 18, fontWeight: FontWeight.w700)),
        Text(label,
          style: const TextStyle(
            color: AppColors.textMuted, fontSize: 10)),
      ]),
    ),
  );
}

// ─── Quick Link ───────────────────────────────────────────────────────────────

class _QuickLink extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickLink({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: AppColors.accentGreen, size: 18),
          const SizedBox(width: 8),
          Text(label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
      ),
    ),
  );
}