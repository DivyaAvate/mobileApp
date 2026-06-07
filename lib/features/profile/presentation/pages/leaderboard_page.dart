import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/constants/api_endpoints.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final leaderboardProvider = FutureProvider<List>((ref) async {
  final dio      = ref.watch(dioProvider);
  final response = await dio.get(ApiEndpoints.leaderboard);
  return response.data as List;
});

// ─── Page ─────────────────────────────────────────────────────────────────────

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: const Text('Leaderboard',
          style: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMuted),
            onPressed: () => ref.invalidate(leaderboardProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border)),
      ),
      body: leaderAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.leaderboard,
                color: AppColors.textMuted, size: 48),
              const SizedBox(height: 12),
              const Text('Failed to load leaderboard',
                style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(leaderboardProvider),
                child: const Text('Retry'),
              ),
            ],
          )),
        data: (users) => users.isEmpty
            ? const Center(
                child: Text('No rankings yet — complete a workout!',
                  style: TextStyle(color: AppColors.textMuted)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (_, i) => _LeaderboardCard(
                  user:  users[i],
                  rank:  i + 1,
                ),
              ),
      ),
    );
  }
}

// ─── Leaderboard Card ─────────────────────────────────────────────────────────

class _LeaderboardCard extends StatelessWidget {
  final dynamic user;
  final int     rank;
  const _LeaderboardCard({required this.user, required this.rank});

  Color get _rankColor {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return AppColors.textMuted;
  }

  String get _rankEmoji {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '$rank';
  }

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTopThree
            ? _rankColor.withValues(alpha: 0.06)
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTopThree
              ? _rankColor.withValues(alpha: 0.3)
              : AppColors.border,
          width: isTopThree ? 1 : 0.5),
      ),
      child: Row(children: [
        // Rank badge
        SizedBox(
          width: 36,
          child: Center(
            child: rank <= 3
                ? Text(_rankEmoji,
                    style: const TextStyle(fontSize: 22))
                : Text('$rank',
                    style: TextStyle(
                      color: _rankColor,
                      fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),

        // Avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.accentGreen.withValues(alpha: 0.15),
          child: Text(
            ((user['displayName'] as String? ?? 'U')[0]).toUpperCase(),
            style: const TextStyle(
              color: AppColors.accentGreen, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),

        // Name + streak
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['displayName'] ?? 'Unknown',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14, fontWeight: FontWeight.w600)),
            Row(children: [
              const Icon(Icons.local_fire_department,
                color: AppColors.accentOrange, size: 12),
              const SizedBox(width: 3),
              Text('${user['streakDays'] ?? user['streak_count'] ?? 0} day streak',
                style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11)),
            ]),
          ],
        )),

        // XP
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${user['xp'] ?? 0} XP',
            style: const TextStyle(
              color: AppColors.accentBlue,
              fontSize: 14, fontWeight: FontWeight.w700)),
          Text('Level ${user['level'] ?? 1}',
            style: const TextStyle(
              color: AppColors.textMuted, fontSize: 11)),
        ]),
      ]),
    );
  }
}