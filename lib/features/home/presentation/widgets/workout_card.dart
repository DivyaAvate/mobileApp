import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../workout/presentation/providers/workout_generator_provider.dart';
import '../../../workout/data/models/workout_plan_model.dart';

class WorkoutCard extends ConsumerWidget {
  const WorkoutCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(workoutGeneratorProvider);

    return planAsync.when(
      // ── Loading ───────────────────────────────────────────
      loading: () => _CardShell(
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen),
        ),
      ),

      // ── Error / No Plan ───────────────────────────────────
      error: (_, __) => _NoPlanCard(onTap: () => context.go('/workout')),

      data: (plan) {
        if (plan == null) return _NoPlanCard(onTap: () => context.go('/workout'));

        // Get today's workout day
        final today     = DateTime.now().weekday; // 1=Mon, 7=Sun
        final dayIndex  = (today - 1) % plan.days.length;
        final todayDay  = plan.days.isNotEmpty ? plan.days[dayIndex] : null;

        if (todayDay == null) return _NoPlanCard(onTap: () => context.go('/workout'));

        final exerciseCount = todayDay.exercises.length;
        final estMinutes    = exerciseCount * 7; // ~7 min per exercise
        final estCalories   = exerciseCount * 45; // ~45 cal per exercise

        return _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Tag ──────────────────────────────────────
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Day ${todayDay.dayNumber} of ${plan.days.length}',
                    style: const TextStyle(
                      color: AppColors.accentGreen,
                      fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _goalLabel(plan.goal),
                  style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11),
                ),
              ]),
              const SizedBox(height: 8),

              // ── Workout Name ──────────────────────────────
              Text(
                todayDay.dayName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),

              // ── Stats ─────────────────────────────────────
              Row(children: [
                _Stat(icon: Icons.fitness_center,
                  label: '$exerciseCount exercises'),
                const SizedBox(width: 14),
                _Stat(icon: Icons.timer_outlined,
                  label: '$estMinutes min'),
                const SizedBox(width: 14),
                _Stat(icon: Icons.local_fire_department,
                  label: '$estCalories cal'),
              ]),
              const SizedBox(height: 16),

              // ── Exercise preview ──────────────────────────
              if (todayDay.exercises.isNotEmpty)
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: todayDay.exercises
                      .take(3)
                      .map((e) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.bgPrimary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.border, width: 0.5),
                            ),
                            child: Text(e.name,
                              style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11)),
                          ))
                      .toList()
                    ..addAll(
                      todayDay.exercises.length > 3
                          ? [Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.bgPrimary,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.border, width: 0.5),
                              ),
                              child: Text(
                                '+${todayDay.exercises.length - 3} more',
                                style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                            )]
                          : [],
                    ),
                ),
              const SizedBox(height: 16),

              // ── Start Button ──────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: AppColors.bgPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => context.push('/active-workout'),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Start Workout',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _goalLabel(String goal) {
    switch (goal) {
      case 'muscle_gain': return '💪 Muscle Gain';
      case 'fat_loss':    return '🔥 Fat Loss';
      case 'strength':    return '⚡ Strength';
      default:            return '❤️ General Fitness';
    }
  }
}

// ─── No Plan Card ─────────────────────────────────────────────────────────────

class _NoPlanCard extends StatelessWidget {
  final VoidCallback onTap;
  const _NoPlanCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NO ACTIVE PLAN',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          const Text('Generate your\nworkout plan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Get a personalised plan based\non your goals and experience.',
            style: TextStyle(
              color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: AppColors.bgPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Generate Plan 🚀',
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card Shell ───────────────────────────────────────────────────────────────

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: child,
    );
  }
}

// ─── Stat Widget ──────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppColors.textMuted, size: 13),
      const SizedBox(width: 4),
      Text(label,
        style: const TextStyle(
          color: AppColors.textMuted, fontSize: 12)),
    ]);
  }
}