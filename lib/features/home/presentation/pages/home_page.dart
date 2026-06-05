import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/providers/gamification_provider.dart';
import '../../../steps/presentation/providers/steps_provider.dart';
import '../../../gym/presentation/providers/gym_provider.dart';
import '../widgets/workout_card.dart';
import '../widgets/xp_progress_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamificationAsync = ref.watch(gamificationProvider);
    final stepsAsync        = ref.watch(stepsProvider);
    final myGymAsync        = ref.watch(myGymProvider);

    final gamification = gamificationAsync.valueOrNull;
    final steps        = stepsAsync.valueOrNull;
    final myGym        = myGymAsync.valueOrNull;

    final hour     = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning'
                   : hour < 17 ? 'Good afternoon'
                   : 'Good evening';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),

              // ── Gym Brand Header ─────────────────────────────────
              if (myGym != null) _buildGymBanner(myGym),
              if (myGym != null) const SizedBox(height: 12),

              // ── User Header ──────────────────────────────────────
              _buildHeader(context, greeting, gamification),
              const SizedBox(height: 16),

              // ── Stats Row ────────────────────────────────────────
              _buildStatsRow(gamification),
              const SizedBox(height: 14),

              // ── Today's Workout ──────────────────────────────────
              const WorkoutCard(),
              const SizedBox(height: 12),

              // ── Gym Offers ───────────────────────────────────────
              if (myGym != null) _buildOffersSection(ref, myGym.id),
              if (myGym != null) const SizedBox(height: 12),

              // ── Step Tracker ─────────────────────────────────────
              _buildStepTracker(steps),
              const SizedBox(height: 12),

              // ── Recovery Score ───────────────────────────────────
              _buildRecoveryScore(),
              const SizedBox(height: 12),

              // ── XP Progress ──────────────────────────────────────
              XPProgressBar(
                currentXP: gamification?.currentXP  ?? 0,
                totalXP:   gamification?.nextLevelXP ?? 3000,
              ),
              const SizedBox(height: 12),

              // ── AI Coach Teaser ──────────────────────────────────
              _buildAICoachTeaser(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Gym Banner ────────────────────────────────────────────────────────────

  Widget _buildGymBanner(GymModel gym) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          // Gym logo / icon
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: gym.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(gym.logoUrl!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.fitness_center,
                    color: AppColors.accentGreen, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gym.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  )),
                if (gym.city != null)
                  Text(gym.city!,
                    style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Member',
              style: TextStyle(
                color: AppColors.accentGreen,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              )),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, String greeting, GamificationState? g) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$greeting 💪',
              style: const TextStyle(
                color: AppColors.textMuted, fontSize: 12)),
            Text('Level ${g?.level ?? 1} Athlete',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20, fontWeight: FontWeight.w600)),
          ],
        ),
        Stack(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.textMuted, size: 20),
                onPressed: () {},
              ),
            ),
            Positioned(
              top: 6, right: 6,
              child: Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow(GamificationState? g) {
    return Row(
      children: [
        _StatMini(
          value:      '${g?.streakDays ?? 0}',
          label:      'Day streak',
          valueColor: AppColors.accentGreen,
        ),
        const SizedBox(width: 8),
        _StatMini(
          value: '${g?.totalWorkouts ?? 0}',
          label: 'Workouts',
        ),
        const SizedBox(width: 8),
        _StatMini(
          value:      'Lv ${g?.level ?? 1}',
          label:      'Current level',
          valueColor: AppColors.accentBlue,
        ),
      ],
    );
  }

  // ── Gym Offers ────────────────────────────────────────────────────────────

  Widget _buildOffersSection(WidgetRef ref, int gymId) {
    final offersAsync = ref.watch(gymOffersProvider(gymId));

    return offersAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (offers) {
        if (offers.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FROM YOUR GYM',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w500,
              )),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: offers.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _OfferChip(offer: offers[i]),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Step Tracker ──────────────────────────────────────────────────────────

  Widget _buildStepTracker(StepsState? steps) {
    final count    = steps?.todaySteps ?? 0;
    final goal     = steps?.goalSteps  ?? 10000;
    final progress = goal > 0 ? (count / goal).clamp(0.0, 1.0) : 0.0;
    final percent  = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64, height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: AppColors.accentGreen.withValues(alpha: 0.12),
                  color: AppColors.accentGreen,
                  strokeCap: StrokeCap.round,
                ),
                Text('$percent%',
                  style: const TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22, fontWeight: FontWeight.w600)),
              const Text('Steps today',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text('Goal: $goal steps',
                style: const TextStyle(
                  color: AppColors.accentGreen, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Recovery Score ────────────────────────────────────────────────────────

  Widget _buildRecoveryScore() {
    const score    = 0.82;
    const scoreInt = 82;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RECOVERY SCORE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11, letterSpacing: 0.8)),
              SizedBox(height: 4),
              Text('$scoreInt',
                style: TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 44, fontWeight: FontWeight.w700, height: 1)),
              SizedBox(height: 4),
              Row(children: [
                Icon(Icons.circle, color: AppColors.accentGreen, size: 8),
                SizedBox(width: 5),
                Text('Train Hard Today',
                  style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 13)),
              ]),
            ],
          ),
          SizedBox(
            height: 80, width: 80,
            child: CircularProgressIndicator(
              value: score,
              strokeWidth: 8,
              backgroundColor: AppColors.accentGreen.withValues(alpha: 0.12),
              color: AppColors.accentGreen,
              strokeCap: StrokeCap.round,
            ),
          ),
        ],
      ),
    );
  }

  // ── AI Coach Teaser ───────────────────────────────────────────────────────

  Widget _buildAICoachTeaser(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/coach'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppColors.accentBlue.withValues(alpha: 0.12),
            AppColors.accentGreen.withValues(alpha: 0.08),
          ]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.accentBlue.withValues(alpha: 0.25), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined,
                color: AppColors.accentBlue, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ask your AI coach anything',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13, fontWeight: FontWeight.w500)),
                  Text('"How do I improve my bench press form?"',
                    style: TextStyle(
                      color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
              color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Offer Chip ───────────────────────────────────────────────────────────────

class _OfferChip extends StatelessWidget {
  final OfferModel offer;
  const _OfferChip({required this.offer});

  @override
  Widget build(BuildContext context) {
    final typeEmoji = {
      'announcement': '📢',
      'offer':        '🏷️',
      'event':        '🎉',
      'challenge':    '⚡',
    }[offer.type] ?? '📢';

    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accentGreen.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(typeEmoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(offer.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13, fontWeight: FontWeight.w600)),
          if (offer.description != null)
            Text(offer.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── Stat Mini Card ───────────────────────────────────────────────────────────

class _StatMini extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _StatMini({
    required this.value,
    required this.label,
    this.valueColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            Text(value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(label,
              style: const TextStyle(
                color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}