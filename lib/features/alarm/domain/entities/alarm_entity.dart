/// Alarm entity — links an alarm to a parent task.
class AlarmEntity {
  const AlarmEntity({
    required this.id,
    required this.taskId,
    required this.scheduledTime,
    this.audioPath = 'assets/audio/gentle_alarm.mp3',
    this.isActive = true,
    this.snoozeCount = 0,
    this.vibrate = true,
    this.overrideDnd = false,
  });

  /// Unique alarm ID (used by the alarm package internally).
  final int id;

  /// Parent task ID.
  final String taskId;

  /// When this alarm should fire.
  final DateTime scheduledTime;

  /// Path to the audio asset or file.
  final String audioPath;

  /// Whether this alarm is currently scheduled.
  final bool isActive;

  /// How many times this alarm has been snoozed today.
  final int snoozeCount;

  /// Whether the device should vibrate.
  final bool vibrate;

  /// Whether to override Do Not Disturb mode.
  final bool overrideDnd;

  AlarmEntity copyWith({
    int? id,
    String? taskId,
    DateTime? scheduledTime,
    String? audioPath,
    bool? isActive,
    int? snoozeCount,
    bool? vibrate,
    bool? overrideDnd,
  }) {
    return AlarmEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      audioPath: audioPath ?? this.audioPath,
      isActive: isActive ?? this.isActive,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      vibrate: vibrate ?? this.vibrate,
      overrideDnd: overrideDnd ?? this.overrideDnd,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'scheduledTime': scheduledTime.toIso8601String(),
        'audioPath': audioPath,
        'isActive': isActive,
        'snoozeCount': snoozeCount,
        'vibrate': vibrate,
        'overrideDnd': overrideDnd,
      };

  factory AlarmEntity.fromJson(Map<String, dynamic> json) => AlarmEntity(
        id: json['id'] as int,
        taskId: json['taskId'] as String,
        scheduledTime: DateTime.parse(json['scheduledTime'] as String),
        audioPath:
            json['audioPath'] as String? ?? 'assets/audio/gentle_alarm.mp3',
        isActive: json['isActive'] as bool? ?? true,
        snoozeCount: json['snoozeCount'] as int? ?? 0,
        vibrate: json['vibrate'] as bool? ?? true,
        overrideDnd: json['overrideDnd'] as bool? ?? false,
      );
}
