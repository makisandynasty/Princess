import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:princes/features/alarm/presentation/controllers/alarm_controller.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/task_local_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

// ─── Providers ─────────────────────────────────────────────────────────────

/// Provides the local datasource singleton.
final taskDatasourceProvider = Provider<TaskLocalDatasource>((ref) {
  final ds = TaskLocalDatasource();
  ref.onDispose(() => ds.dispose());
  return ds;
});

/// Provides the task repository.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.read(taskDatasourceProvider));
});

/// Watches tasks for today as a reactive stream.
final todayTasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  final repo = ref.read(taskRepositoryProvider);
  return repo.watchTasksForDate(DateTime.now());
});

/// Provides daily stats synchronously calculated from the reactive task stream.
final dailyStatsProvider = Provider<({int total, int completed})>((ref) {
  final tasksAsync = ref.watch(todayTasksProvider);
  return tasksAsync.when(
    data: (tasks) => (
      total: tasks.length,
      completed: tasks.where((t) => t.isCompleted).length,
    ),
    loading: () => (total: 0, completed: 0),
    error: (_, __) => (total: 0, completed: 0),
  );
});

/// Task controller for mutations (create, update, delete, toggle).
final taskControllerProvider =
    AsyncNotifierProvider<TaskController, void>(TaskController.new);

// ─── Controller ────────────────────────────────────────────────────────────

/// Handles all task mutation logic.
class TaskController extends AsyncNotifier<void> {
  static const _uuid = Uuid();

  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  @override
  FutureOr<void> build() {}

  /// Create a new task (FR-1.1).
  Future<TaskEntity> createTask({
    required String title,
    String description = '',
    TaskCategory category = TaskCategory.personal,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueTime,
    bool hasAlarm = false,
    DateTime? alarmTime,
    RecurrenceType recurrenceType = RecurrenceType.none,
    List<int> customDays = const [],
    List<SubtaskEntity> subtasks = const [],
    String? photoId,
  }) async {
    final task = TaskEntity(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      priority: priority,
      dueTime: dueTime,
      hasAlarm: hasAlarm,
      alarmTime: alarmTime ?? dueTime,
      recurrenceType: recurrenceType,
      customDays: customDays,
      subtasks: subtasks,
      photoId: photoId,
      createdAt: DateTime.now(),
    );

    final created = await _repo.createTask(task);

    // Schedule alarm if requested
    if (hasAlarm && (alarmTime != null || dueTime != null)) {
      final scheduled = alarmTime ?? dueTime!;
      await ref.read(alarmControllerProvider.notifier).scheduleForTask(
            taskId: created.id,
            scheduledTime: scheduled,
          );
    }

    return created;
  }

  /// Update a task.
  Future<void> updateTask(TaskEntity task) async {
    await _repo.updateTask(task);

    // Handle alarm updates
    if (task.hasAlarm && (task.alarmTime != null || task.dueTime != null)) {
      final scheduled = task.alarmTime ?? task.dueTime!;
      await ref.read(alarmControllerProvider.notifier).scheduleForTask(
            taskId: task.id,
            scheduledTime: scheduled,
          );
    }
  }

  /// Delete a task.
  Future<void> deleteTask(String id) async {
    await _repo.deleteTask(id);
  }

  /// Toggle task completion status.
  Future<void> toggleCompletion(String taskId) async {
    await _repo.toggleTaskCompletion(taskId);
  }

  /// Toggle a subtask's completion (FR-1.3).
  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    await _repo.toggleSubtaskCompletion(taskId, subtaskId);
  }
}
