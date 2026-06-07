import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/workout_generator_provider.dart';
import '../widgets/workout_plan_view.dart';

class WorkoutGenerationScreen extends ConsumerStatefulWidget {
  const WorkoutGenerationScreen({super.key});

  @override
  ConsumerState<WorkoutGenerationScreen> createState() =>
      _WorkoutGenerationScreenState();
}

class _WorkoutGenerationScreenState
    extends ConsumerState<WorkoutGenerationScreen> {
  String _goal       = 'muscle_gain';
  String _experience = 'beginner';
  int    _days       = 3;

  final _goals = const [
    _Option('muscle_gain', '💪', 'Build Muscle'),
    _Option('fat_loss',    '🔥', 'Lose Fat'),
    _Option('strength',    '⚡', 'Build Strength'),
    _Option('general',     '❤️', 'Stay Fit'),
  ];

  final _experiences = const [
    _Option('beginner',     '🌱', 'Beginner'),
    _Option('intermediate', '🌿', 'Intermediate'),
    _Option('advanced',     '🌳', 'Advanced'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutGeneratorProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: const Text('Workout Plan',
          style: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border)),
      ),
      body: state.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.accentGreen),
              SizedBox(height: 16),
              Text('Generating your plan...',
                style: TextStyle(color: AppColors.textMuted)),
            ],
          )),
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
                onPressed: () => ref.read(workoutGeneratorProvider.notifier).reset(),
                child: const Text('Try Again'),
              ),
            ],
          )),
        data: (plan) {
          // ── Plan exists — show it ──────────────────────────
          if (plan != null) {
            return Column(
              children: [
                // Regenerate button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            ref.read(workoutGeneratorProvider.notifier).reset(),
                        icon: const Icon(Icons.refresh,
                          color: AppColors.accentGreen, size: 16),
                        label: const Text('Regenerate',
                          style: TextStyle(color: AppColors.accentGreen)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accentGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/active-workout'),
                        icon: const Icon(Icons.play_arrow, size: 16),
                        label: const Text('Start Today'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: AppColors.bgPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ]),
                ),
                // Plan details
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: WorkoutPlanView(plan: plan),
                  ),
                ),
              ],
            );
          }

          // ── No plan — show generator ───────────────────────
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text('Generate Your Plan',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20, fontWeight: FontWeight.w600)),
                const Text('Tell us your goals and we\'ll build a custom plan.',
                  style: TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 24),

                // ── Goal ──────────────────────────────────────
                _sectionTitle('Your Goal'),
                const SizedBox(height: 10),
                _buildOptionGrid(_goals, _goal,
                  (v) => setState(() => _goal = v)),
                const SizedBox(height: 20),

                // ── Experience ────────────────────────────────
                _sectionTitle('Experience Level'),
                const SizedBox(height: 10),
                _buildOptionGrid(_experiences, _experience,
                  (v) => setState(() => _experience = v)),
                const SizedBox(height: 20),

                // ── Days per week ─────────────────────────────
                _sectionTitle('Days Per Week'),
                const SizedBox(height: 10),
                _buildDaysRow(),
                const SizedBox(height: 32),

                // ── Generate Button ───────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => ref
                        .read(workoutGeneratorProvider.notifier)
                        .generatePlan(_goal, _experience, _days),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: AppColors.bgPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Generate My Plan 🚀',
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
    style: const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 14, fontWeight: FontWeight.w600));

  Widget _buildOptionGrid(
    List<_Option> options, String selected, void Function(String) onSelect) {
    return GridView.count(
      crossAxisCount:  2,
      shrinkWrap:      true,
      physics:         const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing:  10,
      childAspectRatio: 2.2,
      children: options.map((o) => GestureDetector(
        onTap: () => onSelect(o.value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected == o.value
                ? AppColors.accentGreen.withValues(alpha: 0.08)
                : AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected == o.value
                  ? AppColors.accentGreen : AppColors.border,
              width: selected == o.value ? 1.5 : 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(o.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(o.label, style: TextStyle(
                color: selected == o.value
                    ? AppColors.accentGreen : AppColors.textPrimary,
                fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDaysRow() {
    return Row(
      children: [3, 4, 5, 6].map((d) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _days = d),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _days == d
                  ? AppColors.accentGreen.withValues(alpha: 0.08)
                  : AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _days == d
                    ? AppColors.accentGreen : AppColors.border,
                width: _days == d ? 1.5 : 0.5),
            ),
            child: Column(children: [
              Text('$d',
                style: TextStyle(
                  color: _days == d
                      ? AppColors.accentGreen : AppColors.textPrimary,
                  fontSize: 18, fontWeight: FontWeight.w700)),
              Text('days',
                style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 10)),
            ]),
          ),
        ),
      )).toList(),
    );
  }
}

class _Option {
  final String value, emoji, label;
  const _Option(this.value, this.emoji, this.label);
}