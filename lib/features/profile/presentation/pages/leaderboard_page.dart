import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/util/api_client.dart';

final leaderboardProvider = FutureProvider((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/leaderboard/global');
  return response.data as List;
});

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Global Leaderboard")),
      body: leaderAsync.when(
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getRankColor(index),
                child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
              ),
              title: Text(user['displayName'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${user['streak_count']} Day Streak"),
              trailing: Text("${user['xp']} XP", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Color _getRankColor(int index) {
    if (index == 0) return Colors.amber; // Gold
    if (index == 1) return Colors.grey;  // Silver
    if (index == 2) return Colors.brown; // Bronze
    return Colors.blueAccent;
  }
}