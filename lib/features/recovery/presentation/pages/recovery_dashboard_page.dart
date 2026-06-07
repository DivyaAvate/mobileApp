import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/constants/api_endpoints.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class RecoveryData {
  final int    recoveryScore;
  final int    sleepHours;
  final int    sleepMinutes;
  final String sleepQuality;
  final int    sorenessLevel;  // 1-5
  final int    restDaysLeft;
  final String recommendation;

  const RecoveryData({
    this.recoveryScore   = 0,
    this.sleepHours      = 0,
    this.sleepMinutes    = 0,
    this.sleepQuality    = 'Unknown',
    this.sorenessLevel   = 0,
    this.restDaysLeft    = 0,
    this.recommendation  = 'Log your sleep to get recovery insights.',
  });

  factory RecoveryData.fromJson(Map<String, dynamic> j) => RecoveryData(
    recoveryScore:  j['recoveryScore']  as int?    ?? 0,
    sleepHours:     j['sleepHours']     as int?    ?? 0,
    sleepMinutes:   j['sleepMinutes']   as int?    ?? 0,
    sleepQuality:   j['sleepQuality']   as String? ?? 'Unknown',
    sorenessLevel:  j['sorenessLevel']  as int?    ?? 0,
    restDaysLeft:   j['restDaysLeft']   as int?    ?? 0,
    recommendation: j['recommendation'] as String? ??
        'Log your sleep to get recovery insights.',
  );
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final recoveryProvider = FutureProvider<RecoveryData>((ref) async {
  try {
    final dio      = ref.watch(dioProvider);
    final response = await dio.get(ApiEndpoints.recovery);
    return RecoveryData.fromJson(response.data as Map<String, dynamic>);
  } catch (_) {
    return const RecoveryData(); // return empty defaults if no data yet
  }
});

// ─── Page ─────────────────────────────────────────────────────────────────────

class RecoveryDashboardPage extends ConsumerWidget {
  const RecoveryDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recoveryAsync = ref.watch(recoveryProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: const Text('Recovery',
          style: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMuted),
            onPressed: () => ref.invalidate(recoveryProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border)),
      ),
      body: recoveryAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen)),
        error: (e, _) => const Center(
          child: Text('Failed to load recovery data',
            style: TextStyle(color: AppColors.textMuted))),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildScoreCard(data),
              const SizedBox(height: 16),
              _buildSleepCard(data),
              const SizedBox(height: 16),
              _buildSorenessCard(data),
              const SizedBox(height: 16),
              _buildRecommendationCard(data),
              const SizedBox(height: 16),
              _buildLogSleepButton(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  // ── Score Card ────────────────────────────────────────────

  Widget _buildScoreCard(RecoveryData data) {
    final score    = data.recoveryScore;
    final progress = score / 100;
    final color    = score >= 70
        ? AppColors.accentGreen
        : score >= 40 ? AppColors.accentOrange : AppColors.error;
    final status   = score >= 70 ? 'Train Hard'
        : score >= 40 ? 'Train Light' : 'Rest Today';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('RECOVERY SCORE',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11, letterSpacing: 0.8)),
            const SizedBox(height: 4),
            Text('$score',
              style: TextStyle(
                color: color,
                fontSize: 52, fontWeight: FontWeight.w700, height: 1)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.circle, color: color, size: 8),
              const SizedBox(width: 5),
              Text(status,
                style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w500)),
            ]),
          ]),
          SizedBox(
            width: 80, height: 80,
            child: CircularProgressIndicator(
              value:           progress,
              strokeWidth:     8,
              backgroundColor: color.withValues(alpha: 0.12),
              color:           color,
              strokeCap:       StrokeCap.round,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sleep Card ────────────────────────────────────────────

  Widget _buildSleepCard(RecoveryData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bedtime_outlined,
            color: AppColors.accentBlue, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Last Night Sleep',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            Text(
              data.sleepHours > 0
                  ? '${data.sleepHours}h ${data.sleepMinutes}m'
                  : 'Not logged',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(data.sleepQuality,
            style: const TextStyle(
              color: AppColors.accentGreen,
              fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  // ── Soreness Card ─────────────────────────────────────────

  Widget _buildSorenessCard(RecoveryData data) {
    final labels = ['None', 'Mild', 'Moderate', 'High', 'Severe'];
    final colors = [
      AppColors.accentGreen,
      AppColors.accentGreen,
      AppColors.accentOrange,
      AppColors.accentOrange,
      AppColors.error,
    ];
    final level = data.sorenessLevel.clamp(0, 4);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Muscle Soreness',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) => GestureDetector(
              child: Column(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: i == level
                        ? colors[i].withValues(alpha: 0.2)
                        : AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: i == level ? colors[i] : AppColors.border,
                      width: i == level ? 1.5 : 0.5),
                  ),
                  child: Center(
                    child: Text('${i + 1}',
                      style: TextStyle(
                        color: i == level
                            ? colors[i] : AppColors.textMuted,
                        fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(labels[i],
                  style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 9)),
              ]),
            )),
          ),
        ],
      ),
    );
  }

  // ── Recommendation Card ───────────────────────────────────

  Widget _buildRecommendationCard(RecoveryData data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.accentGreen.withValues(alpha: 0.08),
          AppColors.accentBlue.withValues(alpha: 0.06),
        ]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accentGreen.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(children: [
        const Icon(Icons.lightbulb_outline,
          color: AppColors.accentGreen, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(data.recommendation,
            style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 13, height: 1.4)),
        ),
      ]),
    );
  }

  // ── Log Sleep Button ──────────────────────────────────────

  Widget _buildLogSleepButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogSleepSheet(context, ref),
        icon: const Icon(Icons.add, color: AppColors.accentGreen),
        label: const Text('Log Sleep',
          style: TextStyle(color: AppColors.accentGreen)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.accentGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _showLogSleepSheet(BuildContext context, WidgetRef ref) {
    double hours   = 7;
    double minutes = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Log Sleep',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: Column(children: [
                  Text('${hours.toInt()}h',
                    style: const TextStyle(
                      color: AppColors.accentGreen,
                      fontSize: 32, fontWeight: FontWeight.w700)),
                  Slider(
                    value:        hours,
                    min:          0, max: 12,
                    divisions:    24,
                    activeColor:  AppColors.accentGreen,
                    onChanged:    (v) => setState(() => hours = v),
                  ),
                  const Text('Hours',
                    style: TextStyle(color: AppColors.textMuted)),
                ])),
                Expanded(child: Column(children: [
                  Text('${(minutes).toInt()}m',
                    style: const TextStyle(
                      color: AppColors.accentBlue,
                      fontSize: 32, fontWeight: FontWeight.w700)),
                  Slider(
                    value:        minutes,
                    min:          0, max: 59,
                    divisions:    11,
                    activeColor:  AppColors.accentBlue,
                    onChanged:    (v) => setState(() => minutes = v),
                  ),
                  const Text('Minutes',
                    style: TextStyle(color: AppColors.textMuted)),
                ])),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final dio = ref.read(dioProvider);
                    await dio.post(ApiEndpoints.recovery, data: {
                      'sleepHours':   hours.toInt(),
                      'sleepMinutes': minutes.toInt(),
                    });
                    ref.invalidate(recoveryProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Save Sleep'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}