import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🔴 ADD THESE (IMPORTANT)
import 'package:gymbuddy_ai/features/workout/presentation/providers/workout_generator_provider.dart';
import 'package:gymbuddy_ai/features/workout/presentation/widgets/workout_plan_view.dart';

class WorkoutGenerationScreen extends ConsumerStatefulWidget {
  const WorkoutGenerationScreen({super.key});

  @override
  ConsumerState<WorkoutGenerationScreen> createState() =>
      _WorkoutGenerationScreenState();
}

class _WorkoutGenerationScreenState
    extends ConsumerState<WorkoutGenerationScreen> {
  int currentStep = 0;
  String selectedGoal = "muscle_gain";
  String selectedExp = "beginner";
  int selectedDays = 3;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutGeneratorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Plan Generator")),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(
          child: Text("Error: $e"),
        ),

        data: (plan) {
          if (plan != null) {
            return WorkoutPlanView(plan: plan);
          }

          return Stepper(
            currentStep: currentStep,
            onStepContinue: () {
              if (currentStep < 2) {
                setState(() => currentStep++);
              } else {
                // 🔴 FIXED: use correct provider
                ref
                    .read(workoutGeneratorProvider.notifier)
                    .generatePlan(
                      selectedGoal,
                      selectedExp,
                      selectedDays,
                    );
              }
            },
            steps: [
              Step(
                title: const Text("Goal"),
                content: DropdownButton<String>(
                  value: selectedGoal,
                  items: const [
                    DropdownMenuItem(
                        value: "fat_loss", child: Text("fat_loss")),
                    DropdownMenuItem(
                        value: "muscle_gain", child: Text("muscle_gain")),
                    DropdownMenuItem(
                        value: "strength", child: Text("strength")),
                  ],
                  onChanged: (v) =>
                      setState(() => selectedGoal = v!),
                ),
              ),
              Step(
                title: const Text("Experience"),
                content: DropdownButton<String>(
                  value: selectedExp,
                  items: const [
                    DropdownMenuItem(
                        value: "beginner", child: Text("beginner")),
                    DropdownMenuItem(
                        value: "intermediate",
                        child: Text("intermediate")),
                    DropdownMenuItem(
                        value: "advanced", child: Text("advanced")),
                  ],
                  onChanged: (v) =>
                      setState(() => selectedExp = v!),
                ),
              ),
              Step(
                title: const Text("Days Per Week"),
                content: Slider(
                  value: selectedDays.toDouble(),
                  min: 3,
                  max: 6,
                  divisions: 3,
                  onChanged: (v) =>
                      setState(() => selectedDays = v.toInt()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}