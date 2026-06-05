import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gamification_provider.dart';
import '../../data/models/achievement_model.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelData = ref.watch(gamificationProvider);
    final badges = ref.watch(badgesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Rewards & Levels")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Level Progress Card
            levelData.when(
              data: (data) => _LevelCard(
                level: data.level,
                currentXp: data.currentXP,
                nextLevelXp: data.nextLevelXP,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => const Text("Error loading level"),
            ),

            // 2. Badges Grid
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Badges",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            badges.when(
              data: (list) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) => _BadgeItem(badge: list[i]),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Text("Error loading badges"), // ✅ __ for second param
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level, currentXp, nextLevelXp;
  const _LevelCard({
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = currentXp / nextLevelXp;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "LEVEL $level",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900, // ✅ was FontWeight.black (doesn't exist)
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            color: Colors.amber,
          ),
          const SizedBox(height: 10),
          Text(
            "$currentXp / $nextLevelXp XP to Level ${level + 1}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final AchievementModel badge;
  const _BadgeItem({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Opacity(
          opacity: badge.isUnlocked ? 1.0 : 0.3,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage(badge.iconUrl),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          badge.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}