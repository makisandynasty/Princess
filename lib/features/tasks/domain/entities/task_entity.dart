/// Priority levels for tasks.
enum TaskPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}

/// Category types for tasks.
enum TaskCategory {
  work,
  health,
  personal;

  String get label {
    switch (this) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.personal:
        return 'Personal';
    }
  }
}

/// Recurrence rules for repeating tasks.
enum RecurrenceType {
  none,
  daily,
  weekdays,
  weekends,
  custom;

  String get label {
    switch (this) {
      case RecurrenceType.none:
        return 'Once';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekdays:
        return 'Weekdays';
      case RecurrenceType.weekends:
        return 'Weekends';
      case RecurrenceType.custom:
        return 'Custom';
    }
  }
}

/// A subtask/checklist item under a parent task (FR-1.3).
class SubtaskEntity {
  const SubtaskEntity({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final bool isCompleted;

  SubtaskEntity copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubtaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory SubtaskEntity.fromJson(Map<String, dynamic> json) => SubtaskEntity(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

/// Core task entity — pure domain model (FR-1.1).
///
/// Fully supports scheduling alarms, reminders, subtasks, categories,
/// and recurrence patterns.
class TaskEntity {
  const TaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    this.category = TaskCategory.personal,
    this.priority = TaskPriority.medium,
    this.dueTime,
    this.hasAlarm = false,
    this.alarmTime,
    this.recurrenceType = RecurrenceType.none,
    this.customDays = const [],
    this.subtasks = const [],
    this.isCompleted = false,
    this.photoId,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime? dueTime;

  /// Whether a wake-up / high-priority alarm is scheduled for this task.
  final bool hasAlarm;

  /// Exact scheduled time for the alarm (if null, defaults to dueTime).
  final DateTime? alarmTime;

  final RecurrenceType recurrenceType;

  /// For [RecurrenceType.custom]: list of weekday indices (1=Mon, 7=Sun).
  final List<int> customDays;

  final List<SubtaskEntity> subtasks;
  final bool isCompleted;

  /// Optional linked Google Photos media ID.
  final String? photoId;

  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Calculate subtask completion progress (0.0 – 1.0).
  double get subtaskProgress {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completed = subtasks.where((s) => s.isCompleted).length;
    return completed / subtasks.length;
  }

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? dueTime,
    bool? hasAlarm,
    DateTime? alarmTime,
    RecurrenceType? recurrenceType,
    List<int>? customDays,
    List<SubtaskEntity>? subtasks,
    bool? isCompleted,
    String? photoId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueTime: dueTime ?? this.dueTime,
      hasAlarm: hasAlarm ?? this.hasAlarm,
      alarmTime: alarmTime ?? this.alarmTime,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      customDays: customDays ?? this.customDays,
      subtasks: subtasks ?? this.subtasks,
      isCompleted: isCompleted ?? this.isCompleted,
      photoId: photoId ?? this.photoId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.index,
        'priority': priority.index,
        'dueTime': dueTime?.toIso8601String(),
        'hasAlarm': hasAlarm,
        'alarmTime': alarmTime?.toIso8601String(),
        'recurrenceType': recurrenceType.index,
        'customDays': customDays,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'isCompleted': isCompleted,
        'photoId': photoId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory TaskEntity.fromJson(Map<String, dynamic> json) => TaskEntity(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        category: TaskCategory.values[json['category'] as int? ?? 2],
        priority: TaskPriority.values[json['priority'] as int? ?? 1],
        dueTime: json['dueTime'] != null
            ? DateTime.parse(json['dueTime'] as String)
            : null,
        hasAlarm: json['hasAlarm'] as bool? ?? false,
        alarmTime: json['alarmTime'] != null
            ? DateTime.parse(json['alarmTime'] as String)
            : null,
        recurrenceType:
            RecurrenceType.values[json['recurrenceType'] as int? ?? 0],
        customDays: (json['customDays'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            const [],
        subtasks: (json['subtasks'] as List<dynamic>?)
                ?.map(
                    (e) => SubtaskEntity.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        isCompleted: json['isCompleted'] as bool? ?? false,
        photoId: json['photoId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  Map<String, dynamic> toSupabaseMap(String userId) => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'category': category.index,
        'priority': priority.index,
        'due_time': dueTime?.toIso8601String(),
        'has_alarm': hasAlarm,
        'alarm_time': alarmTime?.toIso8601String(),
        'recurrence_type': recurrenceType.index,
        'custom_days': customDays,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'is_completed': isCompleted,
        'photo_id': photoId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
      };

  factory TaskEntity.fromSupabaseMap(Map<String, dynamic> json) => TaskEntity(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        category: TaskCategory.values[json['category'] as int? ?? 2],
        priority: TaskPriority.values[json['priority'] as int? ?? 1],
        dueTime: json['due_time'] != null
            ? DateTime.parse(json['due_time'] as String)
            : null,
        hasAlarm: json['has_alarm'] as bool? ?? false,
        alarmTime: json['alarm_time'] != null
            ? DateTime.parse(json['alarm_time'] as String)
            : null,
        recurrenceType:
            RecurrenceType.values[json['recurrence_type'] as int? ?? 0],
        customDays: (json['custom_days'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            const [],
        subtasks: (json['subtasks'] as List<dynamic>?)
                ?.map(
                    (e) => SubtaskEntity.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        isCompleted: json['is_completed'] as bool? ?? false,
        photoId: json['photo_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );
}
