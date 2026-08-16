import '../../domain/entities/alarm_entity.dart';

/// Wraps the `alarm` package to provide a clean datasource interface.
///
/// TODO: Wire up the actual `alarm` package once dependencies are installed.
/// For now, this provides a stub implementation with logging.
class AlarmNativeDatasource {
  AlarmNativeDatasource();

  final List<AlarmEntity> _scheduledAlarms = [];

  /// Initialize the alarm service.
  /// Must be called in main() before any alarms are scheduled.
  Future<void> init() async {
    // TODO: await Alarm.init();
  }

  /// Schedule an alarm using the native alarm engine.
  Future<void> schedule(AlarmEntity alarm) async {
    // TODO: Use Alarm.set(alarmSettings: AlarmSettings(
    //   id: alarm.id,
    //   dateTime: alarm.scheduledTime,
    //   assetAudioPath: alarm.audioPath,
    //   loopAudio: true,
    //   vibrate: alarm.vibrate,
    //   androidFullScreenIntent: true,
    //   notificationSettings: NotificationSettings(
    //     title: 'Task Reminder',
    //     body: 'Time for your scheduled task',
    //     stopButton: 'Dismiss',
    //   ),
    // ));

    _scheduledAlarms.removeWhere((a) => a.id == alarm.id);
    _scheduledAlarms.add(alarm);
  }

  /// Cancel a scheduled alarm.
  Future<void> cancel(int alarmId) async {
    // TODO: await Alarm.stop(alarmId);
    _scheduledAlarms.removeWhere((a) => a.id == alarmId);
  }

  /// Get all currently scheduled alarms.
  List<AlarmEntity> getScheduled() =>
      List.unmodifiable(_scheduledAlarms);

  /// Check if the app can schedule exact alarms (Android 14+).
  Future<bool> canScheduleExact() async {
    // TODO: Check via permission_handler or platform channel
    return true;
  }

  /// Cancel all scheduled alarms.
  Future<void> cancelAll() async {
    // TODO: await Alarm.stopAll();
    _scheduledAlarms.clear();
  }
}
