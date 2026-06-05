import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/gamification_provider.dart';
import '../../data/models/achievement_model.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelAsync  = ref.watch(gamificationProvider);
    final badgesAsync = ref.watch(badgesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: const Text('Rewards & Levels',
          style: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Level Card ──────────────────────────────────
            levelAsync.when(
              loading: () => const LinearProgressIndicator(
                color: AppColors.accentGreen),
              error: (err, stack) => const SizedBox.shrink(),
              data: (data) => _LevelCard(
                level:      data.level,
                currentXp:  data.currentXP,
                nextLevelXp: data.nextLevelXP,
              ),
            ),
            const SizedBox(height: 20),

            // ── Badges ──────────────────────────────────────
            const Text('BADGES',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w500,
              )),
            const SizedBox(height: 12),

            badgesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accentGreen)),
              error: (err, stack) => const Center(
                child: Text('Failed to load badges',
                  style: TextStyle(color: AppColors.textMuted))),
              data: (list) => list.isEmpty
                  ? const Center(
                      child: Text('No badges yet — keep training!',
                        style: TextStyle(color: AppColors.textMuted)))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:  3,
                          mainAxisSpacing:  10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),
                      itemCount: list.length,
                      itemBuilder: (_, i) => _BadgeItem(badge: list[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Level Card ───────────────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  final int level, currentXp, nextLevelXp;
  const _LevelCard({
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
  });

  @override
  Widget build(BuildContext context) {
    final progress = nextLevelXp > 0
        ? (currentXp / nextLevelXp).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.accentBlue.withValues(alpha: 0.2),
          AppColors.accentGreen.withValues(alpha: 0.15),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentGreen.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('CURRENT LEVEL',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11, letterSpacing: 0.8)),
                Text('$level',
                  style: const TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 48, fontWeight: FontWeight.w700, height: 1)),
              ]),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events,
                  color: AppColors.accentGreen, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.accentGreen.withValues(alpha: 0.12),
              color: AppColors.accentGreen,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$currentXp XP',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12, fontWeight: FontWeight.w500)),
              Text('$nextLevelXp XP to Level ${level + 1}',
                style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Badge Item ───────────────────────────────────────────────────────────────

class _BadgeItem extends StatelessWidget {
  final AchievementModel badge;
  const _BadgeItem({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: badge.isUnlocked ? 1.0 : 0.35,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: badge.isUnlocked
                ? AppColors.accentGreen.withValues(alpha: 0.3)
                : AppColors.border,
            width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            badge.iconUrl.isNotEmpty
                ? Image.network(badge.iconUrl,
                    width: 36, height: 36,
                    errorBuilder: (ctx, err, stack) =>
                      const Icon(Icons.emoji_events,
                        color: AppColors.accentGreen, size: 36))
                : const Icon(Icons.emoji_events,
                    color: AppColors.accentGreen, size: 36),
            const SizedBox(height: 6),
            Text(badge.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: badge.isUnlocked
                    ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 10, fontWeight: FontWeight.w500)),
            if (badge.isUnlocked)
              const Icon(Icons.check_circle,
                color: AppColors.accentGreen, size: 12),
          ],
        ),
      ),
    );
  }
}