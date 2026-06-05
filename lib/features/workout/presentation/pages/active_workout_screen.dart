import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/active_workout_provider.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  // ── Session timer ──────────────────────────────────────────
  late Timer _sessionTimer;
  int _elapsedSeconds = 0;

  // ── Rest timer ─────────────────────────────────────────────
  Timer? _restTimer;
  int _restSeconds = 0;
  bool _restActive = false;
  static const _restDuration = 90; // seconds

  @override
  void initState() {
    super.initState();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _sessionTimer.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() { _restSeconds = _restDuration; _restActive = true; });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restSeconds <= 0) {
        t.cancel();
        setState(() => _restActive = false);
      } else {
        setState(() => _restSeconds--);
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() { _restSeconds = 0; _restActive = false; });
  }

  // ── Add Set Dialog ─────────────────────────────────────────

  void _showAddSetDialog(int exIndex) {
    final weightCtrl = TextEditingController();
    final repsCtrl   = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Log Set',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SheetField(
                    controller: weightCtrl,
                    label: 'Weight (kg)',
                    hint: 'e.g. 60',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SheetField(
                    controller: repsCtrl,
                    label: 'Reps',
                    hint: 'e.g. 8',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: AppColors.bgPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final w = double.tryParse(weightCtrl.text) ?? 0;
                  final r = int.tryParse(repsCtrl.text)    ?? 0;
                  if (w > 0 && r > 0) {
                    ref.read(activeWorkoutProvider.notifier)
                       .addSet(exIndex, weight: w, reps: r);
                    Navigator.pop(ctx);
                    _startRestTimer(); // auto-start rest timer after logging set
                  }
                },
                child: const Text(
                  'Log Set',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Finish Workout ─────────────────────────────────────────

  void _finishWorkout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Finish Workout?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Great session! You trained for ${_formatDuration(_elapsedSeconds)}. Ready to save?',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Keep Going',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: AppColors.bgPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(activeWorkoutProvider.notifier)
                  .finishWorkout();
              if (mounted) {
                if (success) {
                  context.go('/home');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to save. Please try again.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Save & Finish'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(activeWorkoutProvider);

    if (workout == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center,
                color: AppColors.textMuted, size: 48),
              const SizedBox(height: 12),
              const Text(
                'No active workout',
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/workout'),
                child: const Text('Start a Workout'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: _buildAppBar(workout),
      body: Column(
        children: [
          // ── Rest Timer Banner ──────────────────────────────
          if (_restActive) _buildRestBanner(),

          // ── Exercise List ──────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: workout.exercises.length,
              itemBuilder: (_, i) => _ExerciseCard(
                exercise: workout.exercises[i],
                exIndex: i,
                onAddSet: () => _showAddSetDialog(i),
              ),
            ),
          ),
        ],
      ),

      // ── Add Exercise FAB ────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/exercise-list'),
        label: const Text('Add Exercise',
          style: TextStyle(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────

  AppBar _buildAppBar(dynamic workout) {
    return AppBar(
      backgroundColor: AppColors.bgPrimary,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textMuted),
        onPressed: () => context.go('/home'),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workout.name ?? 'Active Workout',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '⏱ ${_formatDuration(_elapsedSeconds)}',
            style: const TextStyle(
              color: AppColors.accentGreen,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _finishWorkout,
          child: const Text(
            'FINISH',
            style: TextStyle(
              color: AppColors.accentGreen,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.border),
      ),
    );
  }

  // ── Rest Timer Banner ──────────────────────────────────────

  Widget _buildRestBanner() {
    final progress = _restSeconds / _restDuration;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.bgCard,
      child: Row(
        children: [
          const Icon(Icons.timer_outlined,
            color: AppColors.accentGreen, size: 18),
          const SizedBox(width: 8),
          const Text('Rest',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.accentGreen.withValues(alpha: 0.12),
                color: AppColors.accentGreen,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDuration(_restSeconds),
            style: const TextStyle(
              color: AppColors.accentGreen,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _skipRest,
            child: const Text('Skip',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ─── Exercise Card ────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final dynamic exercise;
  final int exIndex;
  final VoidCallback onAddSet;

  const _ExerciseCard({
    required this.exercise,
    required this.exIndex,
    required this.onAddSet,
  });

  @override
  Widget build(BuildContext context) {
    final sets = exercise.sets as List;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${exIndex + 1}',
                      style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  exercise.name ?? '',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Sets header row
          if (sets.isNotEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 6, 14, 4),
              child: Row(
                children: [
                  SizedBox(width: 32,
                    child: Text('SET',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 10))),
                  SizedBox(width: 80,
                    child: Text('WEIGHT',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 10))),
                  SizedBox(width: 60,
                    child: Text('REPS',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 10))),
                  Spacer(),
                  Text('PR',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ),

          // Set rows
          ...sets.asMap().entries.map((e) {
            final i   = e.key;
            final set = e.value;
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text('${i + 1}',
                      style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13)),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text('${set.weight} kg',
                      style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13)),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text('× ${set.reps}',
                      style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13)),
                  ),
                  const Spacer(),
                  if (set.isPR == true)
                    const Icon(Icons.emoji_events,
                      color: AppColors.accentOrange, size: 18),
                ],
              ),
            );
          }),

          // Empty state
          if (sets.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 8, 14, 4),
              child: Text(
                'No sets logged yet. Add your first set!',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),

          // Add set button
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: TextButton.icon(
              onPressed: onAddSet,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentGreen,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                'Add Set',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Sheet Field ───────────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(
            color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppColors.bgPrimary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.accentGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}