import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exercise_provider.dart';
import 'exercise_detail_page.dart';

class ExerciseListPage extends ConsumerStatefulWidget {
  const ExerciseListPage({super.key});
  @override
  ConsumerState<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends ConsumerState<ExerciseListPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exerciseListProvider({'search': searchQuery}));

    return Scaffold(
      appBar: AppBar(title: const Text("Exercises")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(hintText: "Search exercises...", prefixIcon: Icon(Icons.search)),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          Expanded(
            child: exercises.when(
              data: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final ex = list[index];
                  return ListTile(
                    title: Text(ex.name),
                    subtitle: Text("${ex.muscleGroup} | ${ex.equipment}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ExerciseDetailPage(exercise: ex)
                    )),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }
}