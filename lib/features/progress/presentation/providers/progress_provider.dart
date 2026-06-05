import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/constants/api_endpoints.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class WeeklyVolume {
  final String label;
  final int    volume;
  const WeeklyVolume({required this.label, required this.volume});
  factory WeeklyVolume.fromJson(Map<String, dynamic> j) => WeeklyVolume(
    label:  j['label']  as String? ?? '',
    volume: j['volume'] as int?    ?? 0,
  );
}

class PersonalRecord {
  final String exerciseName;
  final double weightKg;
  final int    reps;
  const PersonalRecord({
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
  });
  factory PersonalRecord.fromJson(Map<String, dynamic> j) => PersonalRecord(
    exerciseName: j['exerciseName'] as String? ?? '',
    weightKg:     (j['weightKg'] as num?)?.toDouble() ?? 0,
    reps:         j['reps']       as int?    ?? 0,
  );
}

class WeightEntry {
  final DateTime date;
  final double   weight;
  const WeightEntry({required this.date, required this.weight});
  factory WeightEntry.fromJson(Map<String, dynamic> j) => WeightEntry(
    date:   DateTime.parse(j['date'] as String),
    weight: (j['weight'] as num?)?.toDouble() ?? 0,
  );
}

class RecentWorkout {
  final String name;
  final int    totalSets;
  final int    totalVolume;
  final int    durationMin;
  final String dateLabel;
  const RecentWorkout({
    required this.name,
    required this.totalSets,
    required this.totalVolume,
    required this.durationMin,
    required this.dateLabel,
  });
  factory RecentWorkout.fromJson(Map<String, dynamic> j) => RecentWorkout(
    name:        j['name']        as String? ?? 'Workout',
    totalSets:   j['totalSets']   as int?    ?? 0,
    totalVolume: j['totalVolume'] as int?    ?? 0,
    durationMin: ((j['durationSec'] as int? ?? 0) / 60).round(),
    dateLabel:   j['dateLabel']   as String? ?? '',
  );
}

class ProgressData {
  final int                totalWorkouts;
  final int                totalVolume;
  final int                weeklyWorkouts;
  final List<WeeklyVolume> weeklyVolume;
  final List<PersonalRecord> personalRecords;
  final List<WeightEntry>  weightHistory;
  final List<RecentWorkout> recentWorkouts;

  const ProgressData({
    required this.totalWorkouts,
    required this.totalVolume,
    required this.weeklyWorkouts,
    required this.weeklyVolume,
    required this.personalRecords,
    required this.weightHistory,
    required this.recentWorkouts,
  });

  factory ProgressData.fromJson(Map<String, dynamic> j) => ProgressData(
    totalWorkouts:   j['totalWorkouts']   as int? ?? 0,
    totalVolume:     j['totalVolume']     as int? ?? 0,
    weeklyWorkouts:  j['weeklyWorkouts']  as int? ?? 0,
    weeklyVolume:    (j['weeklyVolume']   as List? ?? [])
        .map((e) => WeeklyVolume.fromJson(e)).toList(),
    personalRecords: (j['personalRecords'] as List? ?? [])
        .map((e) => PersonalRecord.fromJson(e)).toList(),
    weightHistory:   (j['weightHistory']  as List? ?? [])
        .map((e) => WeightEntry.fromJson(e)).toList(),
    recentWorkouts:  (j['recentWorkouts'] as List? ?? [])
        .map((e) => RecentWorkout.fromJson(e)).toList(),
  );
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final progressProvider = FutureProvider<ProgressData>((ref) async {
  final dio      = ref.watch(dioProvider);
  final response = await dio.get(ApiEndpoints.progress);
  return ProgressData.fromJson(response.data as Map<String, dynamic>);
});