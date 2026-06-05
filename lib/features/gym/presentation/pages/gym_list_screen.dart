import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/gym_provider.dart';

class GymListScreen extends ConsumerWidget {
  const GymListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymsAsync = ref.watch(gymListProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: const Text('Select Your Gym',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search gyms...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.bgCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
        ),
      ),
      body: gymsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen)),
        error: (e, _) => Center(
          child: Text('Failed to load gyms',
            style: const TextStyle(color: AppColors.textMuted))),
        data: (gyms) => gyms.isEmpty
            ? const Center(
                child: Text('No gyms available',
                  style: TextStyle(color: AppColors.textMuted)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: gyms.length,
                itemBuilder: (_, i) => _GymCard(gym: gyms[i]),
              ),
      ),
    );
  }
}

class _GymCard extends ConsumerWidget {
  final GymModel gym;
  const _GymCard({required this.gym});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinState = ref.watch(joinGymProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: gym.logoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(gym.logoUrl!, fit: BoxFit.cover),
                )
              : const Icon(Icons.fitness_center,
                  color: AppColors.accentGreen, size: 28),
        ),
        title: Text(gym.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (gym.address != null) ...[
              const SizedBox(height: 3),
              Text(gym.address!,
                style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12)),
            ],
            if (gym.city != null)
              Text(gym.city!,
                style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGreen,
            foregroundColor: AppColors.bgPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600),
          ),
          onPressed: joinState.isLoading ? null : () async {
            final success = await ref
                .read(joinGymProvider.notifier)
                .joinGym(gym.id);
            if (success && context.mounted) {
              final state = ref.read(joinGymProvider);
              _showSuccessDialog(context, state.gymName!, state.referralCode!);
            }
          },
          child: joinState.isLoading
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.bgPrimary))
              : const Text('Join'),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String gymName, String code) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎉 Welcome!',
          style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You joined $gymName!',
              style: const TextStyle(color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            const Text('Your referral code:',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentGreen, width: 1),
              ),
              child: Text(code,
                style: const TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                )),
            ),
            const SizedBox(height: 8),
            const Text('Share this with friends to refer them!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: AppColors.bgPrimary,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            child: const Text('Start Training!'),
          ),
        ],
      ),
    );
  }
}