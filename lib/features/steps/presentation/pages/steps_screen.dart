import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/steps_provider.dart';

class StepsScreen extends ConsumerWidget {
  const StepsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepsAsync = ref.watch(stepsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: const Text('Step Tracker',
          style: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMuted),
            onPressed: () => ref.read(stepsProvider.notifier).refresh(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border)),
      ),
      body: stepsAsync.when(
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
                style: const TextStyle(color: AppColors.textMuted),
                textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(stepsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          )),
        data: (stepsState) => RefreshIndicator(
          color: AppColors.accentGreen,
          onRefresh: () => ref.read(stepsProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ── Circle Progress ──────────────────────────
                _buildCircleProgress(stepsState),
                const SizedBox(height: 28),

                // ── Stats Row ────────────────────────────────
                _buildStatRow(stepsState.todaySteps),
                const SizedBox(height: 28),

                // ── Trends ───────────────────────────────────
                if (stepsState.trends.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Last 30 Days',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                  _buildTrendsList(stepsState.trends),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Circle Progress ───────────────────────────────────────

  Widget _buildCircleProgress(StepsState stepsState) {
    final steps    = stepsState.todaySteps;
    final goal     = stepsState.goalSteps;
    final progress = goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0.0;
    final percent  = (progress * 100).toInt();
    final done     = steps >= goal;

    return Column(
      children: [
        SizedBox(
          width: 200, height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value:           progress,
                strokeWidth:     14,
                backgroundColor: AppColors.accentGreen.withValues(alpha: 0.12),
                color:           done
                    ? AppColors.accentGreen
                    : AppColors.accentGreen,
                strokeCap:       StrokeCap.round,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$steps',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 38, fontWeight: FontWeight.w700)),
                  const Text('STEPS',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12, letterSpacing: 1.5)),
                  Text('$percent%',
                    style: const TextStyle(
                      color: AppColors.accentGreen,
                      fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          done ? '🎉 Goal reached!' : 'Goal: $goal steps',
          style: TextStyle(
            color: done ? AppColors.accentGreen : AppColors.textMuted,
            fontSize: 13),
        ),
      ],
    );
  }

  // ── Stat Row ──────────────────────────────────────────────

  Widget _buildStatRow(int steps) {
    final calories = (steps * 0.04).toStringAsFixed(0);
    final distance = (steps * 0.0008).toStringAsFixed(2);

    return Row(children: [
      _StatCard(
        icon:  Icons.local_fire_department,
        color: AppColors.accentOrange,
        value: '$calories kcal',
        label: 'Calories',
      ),
      const SizedBox(width: 12),
      _StatCard(
        icon:  Icons.straighten,
        color: AppColors.accentBlue,
        value: '$distance km',
        label: 'Distance',
      ),
    ]);
  }

  // ── Trends List ───────────────────────────────────────────

  Widget _buildTrendsList(List trends) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trends.length,
      itemBuilder: (_, i) {
        final day      = trends[i];
        final progress = (day.steps / 10000).clamp(0.0, 1.0);
        final reached  = day.steps >= 10000;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: [
              Row(children: [
                Text(
                  '${day.date.day}/${day.date.month}',
                  style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
                const Spacer(),
                Text(
                  '${day.steps} steps',
                  style: TextStyle(
                    color: reached
                        ? AppColors.accentGreen : AppColors.textPrimary,
                    fontSize: 13, fontWeight: FontWeight.w600)),
                if (reached) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle,
                    color: AppColors.accentGreen, size: 14),
                ],
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value:           progress,
                  minHeight:       4,
                  backgroundColor: AppColors.accentGreen.withValues(alpha: 0.1),
                  color:           AppColors.accentGreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   value, label;
  const _StatCard({
    required this.icon, required this.color,
    required this.value, required this.label,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
            style: TextStyle(
              color: color, fontSize: 14, fontWeight: FontWeight.w600)),
          Text(label,
            style: const TextStyle(
              color: AppColors.textMuted, fontSize: 11)),
        ]),
      ]),
    ),
  );
}