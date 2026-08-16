import '../entities/task_entity.dart';

/// Abstract repository interface for task operations.
///
/// Implementation lives in the data layer; this ensures
/// domain logic stays framework-agnostic.
abstract class TaskRepository {
  /// Watch all tasks for a given date as a reactive stream.
  Stream<List<TaskEntity>> watchTasksForDate(DateTime date);

  /// Get all tasks (non-reactive, one-shot).
  Future<List<TaskEntity>> getAllTasks();

  /// Get a single task by ID.
  Future<TaskEntity?> getTaskById(String id);

  /// Create a new task. Returns the created task.
  Future<TaskEntity> createTask(TaskEntity task);

  /// Update an existing task.
  Future<void> updateTask(TaskEntity task);

  /// Delete a task by ID.
  Future<void> deleteTask(String id);

  /// Toggle the completion status of a task.
  Future<void> toggleTaskCompletion(String id);

  /// Toggle a subtask's completion status within a task.
  Future<void> toggleSubtaskCompletion(String taskId, String subtaskId);

  /// Get tasks due within a time range (for alarm scheduling).
  Future<List<TaskEntity>> getTasksDueInRange(DateTime start, DateTime end);

  /// Get completion statistics for a date.
  Future<({int total, int completed})> getStatsForDate(DateTime date);

  /// Export all tasks as JSON for cloud backup.
  Future<List<Map<String, dynamic>>> exportAll();

  /// Import tasks from JSON backup, replacing local data.
  Future<void> importAll(List<Map<String, dynamic>> data);
}
