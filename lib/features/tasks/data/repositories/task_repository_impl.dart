import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';

/// Concrete implementation of [TaskRepository] using local storage.
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._datasource);

  final TaskLocalDatasource _datasource;

  @override
  Stream<List<TaskEntity>> watchTasksForDate(DateTime date) {
    return _datasource.watchAll().map(
          (tasks) => tasks.where((task) {
            if (task.dueTime == null) return false;
            return task.dueTime!.year == date.year &&
                task.dueTime!.month == date.month &&
                task.dueTime!.day == date.day;
          }).toList()
            ..sort((a, b) => (a.dueTime ?? DateTime.now())
                .compareTo(b.dueTime ?? DateTime.now())),
        );
  }

  @override
  Future<List<TaskEntity>> getAllTasks() async => _datasource.getAll();

  @override
  Future<TaskEntity?> getTaskById(String id) async => _datasource.getById(id);

  @override
  Future<TaskEntity> createTask(TaskEntity task) => _datasource.create(task);

  @override
  Future<void> updateTask(TaskEntity task) => _datasource.update(task);

  @override
  Future<void> deleteTask(String id) => _datasource.delete(id);

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final task = _datasource.getById(id);
    if (task == null) return;
    await _datasource.update(task.copyWith(isCompleted: !task.isCompleted));
  }

  @override
  Future<void> toggleSubtaskCompletion(
      String taskId, String subtaskId) async {
    final task = _datasource.getById(taskId);
    if (task == null) return;

    final updatedSubtasks = task.subtasks.map((subtask) {
      if (subtask.id == subtaskId) {
        return subtask.copyWith(isCompleted: !subtask.isCompleted);
      }
      return subtask;
    }).toList();

    // Auto-complete parent task when all subtasks are done
    final allDone = updatedSubtasks.every((s) => s.isCompleted);
    await _datasource.update(task.copyWith(
      subtasks: updatedSubtasks,
      isCompleted: allDone,
    ));
  }

  @override
  Future<List<TaskEntity>> getTasksDueInRange(
          DateTime start, DateTime end) async =>
      _datasource.getDueInRange(start, end);

  @override
  Future<({int total, int completed})> getStatsForDate(
      DateTime date) async {
    final tasks = _datasource.getForDate(date);
    return (
      total: tasks.length,
      completed: tasks.where((t) => t.isCompleted).length,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> exportAll() async =>
      _datasource.exportAll();

  @override
  Future<void> importAll(List<Map<String, dynamic>> data) =>
      _datasource.importAll(data);
}
