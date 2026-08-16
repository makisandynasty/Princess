import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/habit_local_datasource.dart';
import '../../domain/entities/habit_entity.dart';

/// Provides the HabitLocalDatasource singleton
final habitDatasourceProvider = Provider<HabitLocalDatasource>((ref) {
  final ds = HabitLocalDatasource();
  ref.onDispose(() => ds.dispose());
  return ds;
});

/// Streams all active habits
final habitsStreamProvider = StreamProvider<List<HabitEntity>>((ref) {
  final ds = ref.watch(habitDatasourceProvider);
  return ds.watchHabits();
});

/// Habit mutation controller
final habitControllerProvider =
    AsyncNotifierProvider<HabitController, void>(HabitController.new);

class HabitController extends AsyncNotifier<void> {
  HabitLocalDatasource get _ds => ref.read(habitDatasourceProvider);

  @override
  FutureOr<void> build() {}

  Future<void> createHabit({
    required String title,
    String description = '',
    String iconName = 'favorite',
    int colorHex = 0xFFF5C34A,
    int targetDaysPerWeek = 7,
  }) async {
    await _ds.createHabit(
      title: title,
      description: description,
      iconName: iconName,
      colorHex: colorHex,
      targetDaysPerWeek: targetDaysPerWeek,
    );
  }

  Future<void> toggleHabitDay(String habitId, DateTime date) async {
    await _ds.toggleHabitDay(habitId, date);
  }

  Future<void> deleteHabit(String habitId) async {
    await _ds.deleteHabit(habitId);
  }
}
