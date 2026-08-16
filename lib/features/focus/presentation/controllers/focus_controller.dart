import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FocusMode {
  pomodoro(25 * 60, 'Deep Focus', '25 min session'),
  shortBreak(5 * 60, 'Short Break', '5 min recharge'),
  longBreak(15 * 60, 'Long Break', '15 min recovery');

  const FocusMode(this.defaultSeconds, this.title, this.subtitle);
  final int defaultSeconds;
  final String title;
  final String subtitle;
}

class FocusState {
  const FocusState({
    required this.mode,
    required this.remainingSeconds,
    required this.totalDurationSeconds,
    this.isRunning = false,
    this.completedSessions = 0,
    this.totalMinutesFocused = 0,
    this.ambientSound = 'Off',
  });

  final FocusMode mode;
  final int remainingSeconds;
  final int totalDurationSeconds;
  final bool isRunning;
  final int completedSessions;
  final int totalMinutesFocused;
  final String ambientSound;

  double get progress => totalDurationSeconds > 0
      ? (1.0 - (remainingSeconds / totalDurationSeconds)).clamp(0.0, 1.0)
      : 0.0;

  String get formattedTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  FocusState copyWith({
    FocusMode? mode,
    int? remainingSeconds,
    int? totalDurationSeconds,
    bool? isRunning,
    int? completedSessions,
    int? totalMinutesFocused,
    String? ambientSound,
  }) {
    return FocusState(
      mode: mode ?? this.mode,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      isRunning: isRunning ?? this.isRunning,
      completedSessions: completedSessions ?? this.completedSessions,
      totalMinutesFocused: totalMinutesFocused ?? this.totalMinutesFocused,
      ambientSound: ambientSound ?? this.ambientSound,
    );
  }
}

final focusControllerProvider =
    StateNotifierProvider<FocusController, FocusState>((ref) {
  return FocusController();
});

class FocusController extends StateNotifier<FocusState> {
  FocusController()
      : super(const FocusState(
          mode: FocusMode.pomodoro,
          remainingSeconds: 25 * 60,
          totalDurationSeconds: 25 * 60,
        ));

  Timer? _timer;

  void setMode(FocusMode mode) {
    _timer?.cancel();
    state = state.copyWith(
      mode: mode,
      remainingSeconds: mode.defaultSeconds,
      totalDurationSeconds: mode.defaultSeconds,
      isRunning: false,
    );
  }

  void toggleStartPause() {
    if (state.isRunning) {
      _pause();
    } else {
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
      } else {
        _onSessionComplete();
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      remainingSeconds: state.mode.defaultSeconds,
      totalDurationSeconds: state.mode.defaultSeconds,
      isRunning: false,
    );
  }

  void _onSessionComplete() {
    _timer?.cancel();
    final isFocus = state.mode == FocusMode.pomodoro;
    final additionalMinutes = state.totalDurationSeconds ~/ 60;

    state = state.copyWith(
      remainingSeconds: 0,
      isRunning: false,
      completedSessions:
          isFocus ? state.completedSessions + 1 : state.completedSessions,
      totalMinutesFocused: isFocus
          ? state.totalMinutesFocused + additionalMinutes
          : state.totalMinutesFocused,
    );
  }

  void setAmbientSound(String sound) {
    state = state.copyWith(ambientSound: sound);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
