import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/habit_entity.dart';

/// Local persistent datasource for Habits with SharedPreferences.
class HabitLocalDatasource {
  static const String _storageKey = 'princess_habits_vault_v1';
  static const _uuid = Uuid();

  final _habitsController = StreamController<List<HabitEntity>>.broadcast();
  List<HabitEntity> _cache = [];

  Stream<List<HabitEntity>> watchHabits() => _habitsController.stream;

  List<HabitEntity> get currentHabits => List.unmodifiable(_cache);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _cache = list
            .map((item) => HabitEntity.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _cache = _seedDefaultHabits();
        await _save();
      }
    } else {
      _cache = _seedDefaultHabits();
      await _save();
    }

    _habitsController.add(_cache);
  }

  List<HabitEntity> _seedDefaultHabits() {
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final yesterday = now.subtract(const Duration(days: 1));
    final yestKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    return [
      HabitEntity(
        id: _uuid.v4(),
        title: 'Morning Glass of Water 💧',
        description: 'Hydrate right after waking up',
        iconName: 'water_drop',
        colorHex: 0xFF56CCF2,
        targetDaysPerWeek: 7,
        completedDates: [todayKey, yestKey],
        createdAt: now,
      ),
      HabitEntity(
        id: _uuid.v4(),
        title: 'Mindful Morning Meditation 🧘‍♀️',
        description: '10 minutes of serene breathing',
        iconName: 'self_improvement',
        colorHex: 0xFF9D50BB,
        targetDaysPerWeek: 7,
        completedDates: [yestKey],
        createdAt: now,
      ),
      HabitEntity(
        id: _uuid.v4(),
        title: 'Daily Walk or Stretch 🌿',
        description: 'Move body & get fresh air',
        iconName: 'directions_walk',
        colorHex: 0xFF4CAF76,
        targetDaysPerWeek: 6,
        completedDates: [todayKey, yestKey],
        createdAt: now,
      ),
      HabitEntity(
        id: _uuid.v4(),
        title: 'Evening Gratitude Journal 📖',
        description: 'Write down 3 things you love',
        iconName: 'auto_stories',
        colorHex: 0xFFF5C34A,
        targetDaysPerWeek: 7,
        completedDates: [yestKey],
        createdAt: now,
      ),
    ];
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_cache.map((h) => h.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
    _habitsController.add(List.unmodifiable(_cache));
  }

  Future<HabitEntity> createHabit({
    required String title,
    String description = '',
    String iconName = 'favorite',
    int colorHex = 0xFFF5C34A,
    int targetDaysPerWeek = 7,
  }) async {
    final habit = HabitEntity(
      id: _uuid.v4(),
      title: title,
      description: description,
      iconName: iconName,
      colorHex: colorHex,
      targetDaysPerWeek: targetDaysPerWeek,
      createdAt: DateTime.now(),
    );
    _cache.insert(0, habit);
    await _save();
    return habit;
  }

  Future<void> toggleHabitDay(String habitId, DateTime date) async {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final index = _cache.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _cache[index];
    final dates = List<String>.from(habit.completedDates);

    if (dates.contains(key)) {
      dates.remove(key);
    } else {
      dates.add(key);
    }

    _cache[index] = habit.copyWith(completedDates: dates);
    await _save();
  }

  Future<void> deleteHabit(String habitId) async {
    _cache.removeWhere((h) => h.id == habitId);
    await _save();
  }

  void dispose() {
    _habitsController.close();
  }
}
