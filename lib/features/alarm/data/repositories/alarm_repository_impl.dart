import '../../domain/entities/alarm_entity.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../datasources/alarm_native_datasource.dart';

/// Concrete implementation of [AlarmRepository].
class AlarmRepositoryImpl implements AlarmRepository {
  AlarmRepositoryImpl(this._datasource);

  final AlarmNativeDatasource _datasource;

  @override
  Future<void> scheduleAlarm(AlarmEntity alarm) =>
      _datasource.schedule(alarm);

  @override
  Future<void> cancelAlarm(int alarmId) =>
      _datasource.cancel(alarmId);

  @override
  Future<void> snoozeAlarm(int alarmId, Duration duration) async {
    final alarms = _datasource.getScheduled();
    final alarm = alarms.firstWhere(
      (a) => a.id == alarmId,
      orElse: () => throw Exception('Alarm $alarmId not found'),
    );

    // Cancel existing and reschedule with snoozed time
    await _datasource.cancel(alarmId);
    await _datasource.schedule(alarm.copyWith(
      scheduledTime: DateTime.now().add(duration),
      snoozeCount: alarm.snoozeCount + 1,
    ));
  }

  @override
  Future<List<AlarmEntity>> getActiveAlarms() async =>
      _datasource.getScheduled();

  @override
  Future<bool> canScheduleExactAlarms() =>
      _datasource.canScheduleExact();

  @override
  Future<void> openExactAlarmSettings() async {
    // TODO: Use permission_handler or Android intent to open settings
  }

  @override
  Future<void> cancelAll() => _datasource.cancelAll();
}
