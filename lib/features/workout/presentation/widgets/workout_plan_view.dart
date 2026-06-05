import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/workout_plan_model.dart';

class WorkoutPlanView extends StatelessWidget {
  final WorkoutPlanModel plan;
  const WorkoutPlanView({required this.plan, super.key});

  @override
  Widget build(BuildContext context) {
    final days = plan.days;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      itemBuilder: (_, i) {
        final day = days[i];
        final exercises = day.exercises;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: ExpansionTile(
            title: Text(
              'Day ${i + 1} — ${day.dayName}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            iconColor: AppColors.accentGreen,
            collapsedIconColor: AppColors.textMuted,
            children: exercises.map<Widget>((ex) {
              return ListTile(
                leading: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fitness_center,
                    color: AppColors.accentGreen, size: 16),
                ),
                title: Text(
                  ex.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13),
                ),
                subtitle: Text(
                  '${ex.sets} sets × ${ex.reps} reps',
                  style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}