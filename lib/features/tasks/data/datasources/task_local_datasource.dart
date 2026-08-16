import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/task_entity.dart';

/// Hybrid data source for tasks:
/// - Offline / Guest mode: Stored exclusively in local SharedPreferences.
/// - Authenticated mode: Synchronized directly with user's Supabase cloud partition + cached locally.
class TaskLocalDatasource {
  TaskLocalDatasource();

  static const String _storageKey = 'princess_tasks';
  static const String _legacyKey = 'princes_tasks';
  static const _uuid = Uuid();

  final StreamController<List<TaskEntity>> _taskStreamController =
      StreamController<List<TaskEntity>>.broadcast();

  List<TaskEntity> _cachedTasks = [];
  bool _initialized = false;
  StreamSubscription<AuthState>? _authSub;

  /// Initialize the datasource, loading user tasks or starting fresh with 0 tasks.
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    // Clean up any legacy prebuilt seed data
    if (prefs.containsKey(_legacyKey)) {
      await prefs.remove(_legacyKey);
    }

    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _cachedTasks = list
          .map((e) => TaskEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _cachedTasks = [];
    }

    // Listen to Auth State Changes
    _authSub = SupabaseService.instance.authStateChanges?.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        syncFromCloud();
      } else if (data.event == AuthChangeEvent.signedOut) {
        // Reset or keep offline tasks
        _notifyListeners();
      }
    });

    // If already signed in at startup, fetch from Supabase
    if (SupabaseService.instance.isAuthenticated) {
      await syncFromCloud();
    }

    _initialized = true;
    _notifyListeners();
  }

  /// Sync data between local storage and Supabase cloud.
  Future<void> syncFromCloud() async {
    final user = SupabaseService.instance.currentUser;
    if (user == null) return;

    try {
      final response = await SupabaseService.instance.client
          .from('tasks')
          .select()
          .eq('user_id', user.id);

      final cloudTasks = (response as List<dynamic>)
          .map((item) => TaskEntity.fromSupabaseMap(item as Map<String, dynamic>))
          .toList();

      // Merge: if local task is not in cloud, upload it
      final cloudIds = cloudTasks.map((t) => t.id).toSet();
      for (final local in _cachedTasks) {
        if (!cloudIds.contains(local.id)) {
          await _uploadToCloud(local, user.id);
          cloudTasks.add(local);
        }
      }

      _cachedTasks = cloudTasks;
      await _persist();
      _notifyListeners();
    } catch (e) {
      debugPrint('Error syncing tasks from Supabase: $e');
    }
  }

  /// Watch all tasks as a reactive stream, emitting current state immediately.
  Stream<List<TaskEntity>> watchAll() async* {
    yield List.unmodifiable(_cachedTasks);
    yield* _taskStreamController.stream;
  }

  /// Get all tasks (one-shot).
  List<TaskEntity> getAll() => List.unmodifiable(_cachedTasks);

  /// Get a task by ID.
  TaskEntity? getById(String id) {
    try {
      return _cachedTasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create a new task.
  Future<TaskEntity> create(TaskEntity task) async {
    final newTask = task.copyWith(
      id: task.id.isEmpty ? _uuid.v4() : null,
      createdAt: DateTime.now(),
    );
    _cachedTasks.add(newTask);
    await _persist();
    _notifyListeners();

    // Sync to Supabase if authenticated
    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      unawaited(_uploadToCloud(newTask, user.id));
    }

    return newTask;
  }

  /// Update an existing task.
  Future<void> update(TaskEntity task) async {
    final index = _cachedTasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;
    final updated = task.copyWith(updatedAt: DateTime.now());
    _cachedTasks[index] = updated;
    await _persist();
    _notifyListeners();

    // Sync update to Supabase if authenticated
    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      unawaited(_uploadToCloud(updated, user.id));
    }
  }

  /// Delete a task by ID.
  Future<void> delete(String id) async {
    _cachedTasks.removeWhere((t) => t.id == id);
    await _persist();
    _notifyListeners();

    // Sync deletion to Supabase if authenticated
    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      try {
        unawaited(
          SupabaseService.instance.client
              .from('tasks')
              .delete()
              .eq('id', id)
              .eq('user_id', user.id),
        );
      } catch (e) {
        debugPrint('Error deleting task from cloud: $e');
      }
    }
  }

  /// Clear all tasks for a completely fresh start.
  Future<void> clearAll() async {
    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      try {
        await SupabaseService.instance.client
            .from('tasks')
            .delete()
            .eq('user_id', user.id);
      } catch (e) {
        debugPrint('Error clearing tasks from cloud: $e');
      }
    }

    _cachedTasks.clear();
    await _persist();
    _notifyListeners();
  }

  /// Get tasks for a specific date.
  List<TaskEntity> getForDate(DateTime date) {
    return _cachedTasks.where((task) {
      if (task.dueTime == null) return false;
      return task.dueTime!.year == date.year &&
          task.dueTime!.month == date.month &&
          task.dueTime!.day == date.day;
    }).toList()
      ..sort((a, b) => (a.dueTime ?? DateTime.now())
          .compareTo(b.dueTime ?? DateTime.now()));
  }

  /// Get tasks due within a time range.
  List<TaskEntity> getDueInRange(DateTime start, DateTime end) {
    return _cachedTasks.where((task) {
      if (task.dueTime == null) return false;
      return task.dueTime!.isAfter(start) && task.dueTime!.isBefore(end);
    }).toList();
  }

  /// Export all tasks as serializable JSON maps.
  List<Map<String, dynamic>> exportAll() {
    return _cachedTasks.map((t) => t.toJson()).toList();
  }

  /// Import tasks from JSON, replacing local data.
  Future<void> importAll(List<Map<String, dynamic>> data) async {
    _cachedTasks =
        data.map((json) => TaskEntity.fromJson(json)).toList();
    await _persist();
    _notifyListeners();

    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      for (final t in _cachedTasks) {
        await _uploadToCloud(t, user.id);
      }
    }
  }

  /// Generate a new unique ID.
  String generateId() => _uuid.v4();

  // ─── Private Helpers ──────────────────────────────────────────────

  Future<void> _uploadToCloud(TaskEntity task, String userId) async {
    try {
      await SupabaseService.instance.client
          .from('tasks')
          .upsert(task.toSupabaseMap(userId));
    } catch (e) {
      debugPrint('Error uploading task to Supabase: $e');
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_cachedTasks.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, json);
  }

  void _notifyListeners() {
    _taskStreamController.add(List.unmodifiable(_cachedTasks));
  }

  /// Dispose the stream controller.
  void dispose() {
    _authSub?.cancel();
    _taskStreamController.close();
  }
}
