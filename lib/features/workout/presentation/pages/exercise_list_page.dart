import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/exercise_provider.dart';
import '../../data/models/exercise_model.dart';
import 'exercise_detail_page.dart';

class ExerciseListPage extends ConsumerStatefulWidget {
  const ExerciseListPage({super.key});

  @override
  ConsumerState<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends ConsumerState<ExerciseListPage> {
  String _search       = '';
  String _muscleFilter = 'all';

  final _muscles = [
    'all', 'chest', 'back', 'legs',
    'shoulders', 'arms', 'core',
  ];

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(
      exerciseListProvider({'search': _search, 'muscle': _muscleFilter}));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('Exercise Library',
          style: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border)),
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText:  'Search exercises...',
                hintStyle: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search,
                  color: AppColors.textMuted, size: 20),
                filled:     true,
                fillColor:  AppColors.bgCard,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.accentGreen, width: 1.5)),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // ── Muscle Filter Chips ─────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _muscles.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final m        = _muscles[i];
                final selected = _muscleFilter == m;
                return GestureDetector(
                  onTap: () => setState(() => _muscleFilter = m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accentGreen
                          : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.accentGreen : AppColors.border,
                        width: 0.5),
                    ),
                    child: Text(
                      m == 'all' ? 'All' : m[0].toUpperCase() + m.substring(1),
                      style: TextStyle(
                        color: selected
                            ? AppColors.bgPrimary : AppColors.textMuted,
                        fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // ── Exercise List ───────────────────────────────
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accentGreen)),
              error: (e, _) => Center(
                child: Text('Error: $e',
                  style: const TextStyle(color: AppColors.textMuted))),
              data: (list) => list.isEmpty
                  ? const Center(
                      child: Text('No exercises found',
                        style: TextStyle(color: AppColors.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: list.length,
                      itemBuilder: (_, i) =>
                          _ExerciseCard(exercise: list[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Exercise Card ────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ExerciseDetailPage(exercise: exercise))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          // Muscle icon
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fitness_center,
              color: AppColors.accentGreen, size: 22),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exercise.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Row(children: [
                _Tag(exercise.muscleGroup, AppColors.accentGreen),
                const SizedBox(width: 6),
                if (exercise.equipment.isNotEmpty)
                  _Tag(exercise.equipment, AppColors.accentBlue),
              ]),
            ],
          )),
          const Icon(Icons.chevron_right,
            color: AppColors.textMuted, size: 18),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color  color;
  const _Tag(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(text,
      style: TextStyle(
        color: color, fontSize: 10, fontWeight: FontWeight.w500)),
  );
}