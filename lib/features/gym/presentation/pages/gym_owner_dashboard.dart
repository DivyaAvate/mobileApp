import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../providers/gym_provider.dart';

class GymOwnerDashboard extends ConsumerStatefulWidget {
  const GymOwnerDashboard({super.key});

  @override
  ConsumerState<GymOwnerDashboard> createState() => _GymOwnerDashboardState();
}

class _GymOwnerDashboardState extends ConsumerState<GymOwnerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myGym = ref.watch(myGymProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(myGym?.name ?? 'My Gym',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17, fontWeight: FontWeight.w600)),
            const Text('Owner Dashboard',
              style: TextStyle(color: AppColors.accentGreen, fontSize: 11)),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.accentGreen,
          labelColor: AppColors.accentGreen,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'Members'),
            Tab(text: 'Offers'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: myGym == null
          ? const Center(
              child: Text('No gym found',
                style: TextStyle(color: AppColors.textMuted)))
          : TabBarView(
              controller: _tabs,
              children: [
                _MembersTab(gymId: myGym.id),
                _OffersTab(gymId: myGym.id),
                _AnalyticsTab(gymId: myGym.id),
              ],
            ),
    );
  }
}

// ─── Members Tab ──────────────────────────────────────────────────────────────

class _MembersTab extends ConsumerWidget {
  final int gymId;
  const _MembersTab({required this.gymId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(_gymMembersProvider(gymId));

    return membersAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accentGreen)),
      error: (e, _) => Center(
        child: Text('$e', style: const TextStyle(color: AppColors.error))),
      data: (members) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: members.length,
        itemBuilder: (_, i) {
          final m = members[i]['user'];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.accentGreen.withValues(alpha: 0.15),
                child: Text(
                  (m['displayName'] as String? ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.accentGreen, fontWeight: FontWeight.w600),
                ),
              ),
              title: Text(m['displayName'] ?? 'Unknown',
                style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              subtitle: Text('Level ${m['level']} · ${m['xp']} XP',
                style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12)),
              trailing: const Icon(
                Icons.chevron_right, color: AppColors.textMuted),
              onTap: () => _showMemberDetail(context, ref, gymId, m['id']),
            ),
          );
        },
      ),
    );
  }

  void _showMemberDetail(BuildContext context, WidgetRef ref, int gymId, int memberId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _MemberDetailSheet(gymId: gymId, memberId: memberId),
    );
  }
}

class _MemberDetailSheet extends ConsumerWidget {
  final int gymId;
  final int memberId;
  const _MemberDetailSheet({required this.gymId, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_memberDataProvider((gymId: gymId, memberId: memberId)));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => dataAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen)),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: AppColors.error))),
        data: (data) {
          final user     = data['user'];
          final logs     = data['workoutLogs'] as List? ?? [];
          return ListView(
            controller: ctrl,
            padding: const EdgeInsets.all(20),
            children: [
              // Member header
              Row(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.accentGreen.withValues(alpha: 0.15),
                  child: Text(
                    (user['displayName'] as String? ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.accentGreen,
                      fontSize: 22, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user['displayName'] ?? '',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17, fontWeight: FontWeight.w600)),
                  Text(user['email'] ?? '',
                    style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
                  Text('Level ${user['level']} · ${user['xp']} XP',
                    style: const TextStyle(
                      color: AppColors.accentGreen, fontSize: 12)),
                ]),
              ]),
              const SizedBox(height: 20),
              const Text('WORKOUT HISTORY',
                style: TextStyle(color: AppColors.textMuted,
                  fontSize: 11, letterSpacing: 1)),
              const SizedBox(height: 10),
              ...logs.map((log) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(children: [
                  const Icon(Icons.fitness_center,
                    color: AppColors.accentGreen, size: 16),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log['name'] ?? 'Workout',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13, fontWeight: FontWeight.w500)),
                      Text('Volume: ${log['totalVolume']} kg · ${log['totalSets']} sets',
                        style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                    ],
                  )),
                ]),
              )),
            ],
          );
        },
      ),
    );
  }
}

// ─── Offers Tab ───────────────────────────────────────────────────────────────

class _OffersTab extends ConsumerWidget {
  final int gymId;
  const _OffersTab({required this.gymId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(gymOffersProvider(gymId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentGreen,
        foregroundColor: AppColors.bgPrimary,
        onPressed: () => _showCreateOfferSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Offer'),
      ),
      body: offers.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen)),
        error: (e, _) => const Center(
          child: Text('Failed to load offers',
            style: TextStyle(color: AppColors.textMuted))),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text('No offers yet. Create your first!',
                  style: TextStyle(color: AppColors.textMuted)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: list.length,
                itemBuilder: (_, i) => _OfferCard(offer: list[i], gymId: gymId),
              ),
      ),
    );
  }

  void _showCreateOfferSheet(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    String selectedType = 'announcement';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create Offer',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. 20% off protein supplements'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Details about the offer...'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                dropdownColor: AppColors.bgCard,
                style: const TextStyle(color: AppColors.textPrimary),
                items: const [
                  DropdownMenuItem(value: 'announcement', child: Text('📢 Announcement')),
                  DropdownMenuItem(value: 'offer',        child: Text('🏷️ Offer / Deal')),
                  DropdownMenuItem(value: 'event',        child: Text('🎉 Event')),
                  DropdownMenuItem(value: 'challenge',    child: Text('⚡ Challenge')),
                ],
                onChanged: (v) => setState(() => selectedType = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final dio = ref.read(dioProvider);
                    await dio.post(
                      ApiEndpoints.gymOffers(gymId.toString()),
                      data: {
                        'title':       titleCtrl.text,
                        'description': descCtrl.text,
                        'type':        selectedType,
                      },
                    );
                    ref.invalidate(gymOffersProvider(gymId));
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Post Offer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends ConsumerWidget {
  final OfferModel offer;
  final int gymId;
  const _OfferCard({required this.offer, required this.gymId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeEmoji = {
      'announcement': '📢',
      'offer':        '🏷️',
      'event':        '🎉',
      'challenge':    '⚡',
    }[offer.type] ?? '📢';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        Text(typeEmoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(offer.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600, fontSize: 14)),
            if (offer.description != null)
              Text(offer.description!,
                style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12)),
          ],
        )),
        IconButton(
          icon: const Icon(Icons.delete_outline,
            color: AppColors.error, size: 20),
          onPressed: () async {
            final dio = ref.read(dioProvider);
            await dio.delete(
              ApiEndpoints.deleteOffer(gymId.toString(), offer.id.toString()));
            ref.invalidate(gymOffersProvider(gymId));
          },
        ),
      ]),
    );
  }
}

// ─── Analytics Tab ────────────────────────────────────────────────────────────

class _AnalyticsTab extends ConsumerWidget {
  final int gymId;
  const _AnalyticsTab({required this.gymId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(_gymMembersProvider(gymId));
    final total   = members.valueOrNull?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          _StatCard(label: 'Total Members', value: '$total', icon: Icons.people),
          const SizedBox(width: 10),
          _StatCard(label: 'Active Today',  value: '-',     icon: Icons.local_fire_department),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _StatCard(label: 'Workouts Today', value: '-', icon: Icons.fitness_center),
          const SizedBox(width: 10),
          _StatCard(label: 'Avg Level',      value: '-', icon: Icons.star),
        ]),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(children: [
          Icon(icon, color: AppColors.accentGreen, size: 24),
          const SizedBox(height: 8),
          Text(value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24, fontWeight: FontWeight.w700)),
          Text(label,
            style: const TextStyle(
              color: AppColors.textMuted, fontSize: 11),
            textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ─── Internal Providers ───────────────────────────────────────────────────────

final _gymMembersProvider = FutureProvider.family<List, int>((ref, gymId) async {
  final dio      = ref.watch(dioProvider);
  final response = await dio.get(ApiEndpoints.gymMembers(gymId.toString()));
  return response.data as List;
});

final _memberDataProvider = FutureProvider.family<Map, ({int gymId, int memberId})>(
  (ref, args) async {
    final dio      = ref.watch(dioProvider);
    final response = await dio.get(
      ApiEndpoints.memberData(args.gymId.toString(), args.memberId.toString()));
    return response.data as Map;
  },
);