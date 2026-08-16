import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../tasks/data/datasources/task_local_datasource.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';
import 'sound_service.dart';

/// State of currently ringing alarm (if any)
class AlarmState {
  const AlarmState({
    this.ringingTask,
    this.isRinging = false,
  });

  final TaskEntity? ringingTask;
  final bool isRinging;
}

/// Service that continuously monitors scheduled tasks and triggers real, loud buzzing alarms.
class AlarmSchedulerService extends StateNotifier<AlarmState> {
  AlarmSchedulerService(this._taskDatasource, this._soundService)
      : super(const AlarmState()) {
    _init();
  }

  final TaskLocalDatasource _taskDatasource;
  final SoundService _soundService;

  Timer? _heartbeatTimer;
  StreamSubscription<List<TaskEntity>>? _taskSubscription;
  final Set<String> _acknowledgedAlarms = {};
  GoRouter? _router;

  void attachRouter(GoRouter router) {
    _router = router;
  }

  void _init() {
    // Listen to task stream
    _taskSubscription = _taskDatasource.watchAll().listen((tasks) {
      _logArmedAlarms(tasks);
      _checkPendingAlarms();
    });

    // Start 1-second interval heartbeat
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      try {
        _checkPendingAlarms();
      } catch (e, st) {
        debugPrint('Alarm scheduler error: $e\n$st');
      }
    });
  }

  void _logArmedAlarms(List<TaskEntity> tasks) {
    final alarms = tasks.where((t) => t.hasAlarm && !t.isCompleted).toList();
    debugPrint('⏰ Scheduler monitoring ${alarms.length} active alarm(s):');
    for (final a in alarms) {
      final t = a.alarmTime ?? a.dueTime;
      debugPrint('   -> "${a.title}" set for: $t');
    }
  }

  void _checkPendingAlarms() {
    final tasks = _taskDatasource.getAll();
    final now = DateTime.now();

    for (final task in tasks) {
      if (task.isCompleted) continue;

      final hasAlarm = task.hasAlarm;
      final targetTime = task.alarmTime ?? task.dueTime;

      if (!hasAlarm || targetTime == null) continue;

      // Unique key for this specific alarm minute
      final alarmKey =
          '${task.id}_${targetTime.year}_${targetTime.month}_${targetTime.day}_${targetTime.hour}_${targetTime.minute}';

      if (_acknowledgedAlarms.contains(alarmKey)) continue;

      // Compare target time with current time (ignore seconds precision)
      final isSameDay = now.year == targetTime.year &&
          now.month == targetTime.month &&
          now.day == targetTime.day;

      final diffSeconds = now.difference(targetTime).inSeconds;

      // Ring if current time is within 0s to 300s (5 minutes) after scheduled time today
      // OR if hour and minute match exactly today
      final isCurrentMinute = isSameDay &&
          now.hour == targetTime.hour &&
          now.minute == targetTime.minute;

      if (isCurrentMinute || (isSameDay && diffSeconds >= 0 && diffSeconds <= 300)) {
        _triggerAlarm(task, alarmKey);
        break;
      }
    }
  }

  void _triggerAlarm(TaskEntity task, String alarmKey) {
    _acknowledgedAlarms.add(alarmKey);
    state = AlarmState(ringingTask: task, isRinging: true);

    debugPrint('🚨🚨🚨 ALARM TRIGGERED NOW: "${task.title}" 🚨🚨🚨');

    // Start loud looping audio & haptic buzzer
    _soundService.startAlarmLoop();

    // Navigate to full-screen alarm screen if router is attached
    if (_router != null) {
      try {
        _router!.push('/alarm?taskId=${task.id}');
      } catch (e) {
        debugPrint('Router navigation error: $e');
      }
    }
  }

  /// Manually trigger a test alarm immediately
  void triggerTestAlarm([TaskEntity? testTask]) {
    final task = testTask ??
        TaskEntity(
          id: 'test_alarm_id',
          title: 'Test Wake-Up Alarm',
          description: 'Testing live loud alarm buzzing & sound playback',
          createdAt: DateTime.now(),
          hasAlarm: true,
          alarmTime: DateTime.now(),
        );

    _triggerAlarm(task, 'test_${DateTime.now().millisecondsSinceEpoch}');
  }

  /// Snooze the ringing alarm for specified minutes (default 10)
  Future<void> snoozeCurrentAlarm([int minutes = 10]) async {
    await _soundService.stop();
    final task = state.ringingTask;
    state = const AlarmState(ringingTask: null, isRinging: false);

    if (task != null && task.id != 'test_alarm_id') {
      final newTime = DateTime.now().add(Duration(minutes: minutes));
      final updated = task.copyWith(
        hasAlarm: true,
        alarmTime: newTime,
        updatedAt: DateTime.now(),
      );
      await _taskDatasource.update(updated);
      debugPrint('😴 Snoozed "${task.title}" to $newTime');
    }
  }

  /// Dismiss and turn off the active alarm
  Future<void> dismissCurrentAlarm() async {
    await _soundService.stop();
    final task = state.ringingTask;
    state = const AlarmState(ringingTask: null, isRinging: false);

    if (task != null && task.id != 'test_alarm_id') {
      final updated = task.copyWith(
        hasAlarm: false,
        updatedAt: DateTime.now(),
      );
      await _taskDatasource.update(updated);
      debugPrint('⏹️ Dismissed alarm for "${task.title}"');
    }
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    _heartbeatTimer?.cancel();
    _soundService.stop();
    super.dispose();
  }
}

/// Global provider for AlarmSchedulerService
final alarmSchedulerServiceProvider =
    StateNotifierProvider<AlarmSchedulerService, AlarmState>((ref) {
  final ds = ref.watch(taskDatasourceProvider);
  final sound = ref.watch(soundServiceProvider);
  return AlarmSchedulerService(ds, sound);
});
