import '../entities/alarm_entity.dart';

/// Abstract repository interface for alarm operations.
abstract class AlarmRepository {
  /// Schedule a new alarm.
  Future<void> scheduleAlarm(AlarmEntity alarm);

  /// Cancel a scheduled alarm.
  Future<void> cancelAlarm(int alarmId);

  /// Snooze an alarm by the given duration.
  Future<void> snoozeAlarm(int alarmId, Duration duration);

  /// Get all active alarms.
  Future<List<AlarmEntity>> getActiveAlarms();

  /// Check if exact alarms can be scheduled (Android 14+).
  Future<bool> canScheduleExactAlarms();

  /// Open system settings for exact alarm permission.
  Future<void> openExactAlarmSettings();

  /// Cancel all alarms.
  Future<void> cancelAll();
}
