import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetflixModeState {
  final int currentExerciseIndex;
  final int remainingRestTime;
  final bool isResting;

  NetflixModeState({
    this.currentExerciseIndex = 0,
    this.remainingRestTime = 0,
    this.isResting = false,
  });

  NetflixModeState copyWith({int? index, int? restTime, bool? resting}) {
    return NetflixModeState(
      currentExerciseIndex: index ?? currentExerciseIndex,
      remainingRestTime: restTime ?? remainingRestTime,
      isResting: resting ?? isResting,
    );
  }
}

class NetflixModeNotifier extends StateNotifier<NetflixModeState> {
  NetflixModeNotifier() : super(NetflixModeState());
  Timer? _timer;

  void startRest(int seconds) {
    state = state.copyWith(resting: true, restTime: seconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.remainingRestTime > 0) {
        state = state.copyWith(restTime: state.remainingRestTime - 1);
      } else {
        stopRest();
      }
    });
  }

  void stopRest() {
    _timer?.cancel();
    state = state.copyWith(resting: false, restTime: 0);
  }

  void nextExercise() {
    state = state.copyWith(index: state.currentExerciseIndex + 1);
    stopRest();
  }
}

final netflixModeProvider = StateNotifierProvider<NetflixModeNotifier, NetflixModeState>((ref) {
  return NetflixModeNotifier();
});