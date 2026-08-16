import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/datasources/alarm_native_datasource.dart';
import '../../data/repositories/alarm_repository_impl.dart';
import '../../domain/entities/alarm_entity.dart';
import '../../domain/repositories/alarm_repository.dart';

// ─── Providers ─────────────────────────────────────────────────────────────

final alarmDatasourceProvider = Provider<AlarmNativeDatasource>((ref) {
  return AlarmNativeDatasource();
});

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepositoryImpl(ref.read(alarmDatasourceProvider));
});

final alarmControllerProvider =
    AsyncNotifierProvider<AlarmController, List<AlarmEntity>>(
        AlarmController.new);

// ─── Controller ────────────────────────────────────────────────────────────

/// Manages alarm scheduling, snoozing, and dismissal.
class AlarmController extends AsyncNotifier<List<AlarmEntity>> {
  AlarmRepository get _repo => ref.read(alarmRepositoryProvider);

  @override
  FutureOr<List<AlarmEntity>> build() async {
    return _repo.getActiveAlarms();
  }

  /// Schedule a new alarm for a task.
  Future<void> scheduleForTask({
    required String taskId,
    required DateTime scheduledTime,
    String audioPath = 'assets/audio/gentle_alarm.mp3',
    bool vibrate = true,
    bool overrideDnd = false,
  }) async {
    final alarm = AlarmEntity(
      id: scheduledTime.millisecondsSinceEpoch ~/ 1000,
      taskId: taskId,
      scheduledTime: scheduledTime,
      audioPath: audioPath,
      vibrate: vibrate,
      overrideDnd: overrideDnd,
    );

    await _repo.scheduleAlarm(alarm);
    ref.invalidateSelf();
  }

  /// Snooze an active alarm.
  Future<void> snooze(int alarmId) async {
    await _repo.snoozeAlarm(
      alarmId,
      const Duration(
          minutes: AppConstants.defaultSnoozeDurationMinutes),
    );
    ref.invalidateSelf();
  }

  /// Dismiss (cancel) an alarm.
  Future<void> dismiss(int alarmId) async {
    await _repo.cancelAlarm(alarmId);
    ref.invalidateSelf();
  }

  /// Cancel all alarms.
  Future<void> cancelAll() async {
    await _repo.cancelAll();
    ref.invalidateSelf();
  }

  /// Check if exact alarms are permitted.
  Future<bool> canScheduleExact() =>
      _repo.canScheduleExactAlarms();

  /// Open system settings for exact alarm permission.
  Future<void> openExactAlarmSettings() =>
      _repo.openExactAlarmSettings();
}
