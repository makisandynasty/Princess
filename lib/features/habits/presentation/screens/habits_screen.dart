import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:princes/app/theme/color_scheme.dart';
import 'package:princes/features/habits/domain/entities/habit_entity.dart';
import 'package:princes/features/habits/presentation/controllers/habit_controller.dart';

/// Full-featured Habit Tracker screen with calendar heatmaps and streak counters.
class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF130D1B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Habit Rituals',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              Text(
                'Nurture your daily routine & streaks',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFD1C2D2),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColorScheme.primaryGold, size: 28),
            onPressed: () => _showAddHabitSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.spa_rounded,
                    size: 64,
                    color: Color(0xFF9D50BB),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No habits created yet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create small daily rituals for lasting growth',
                    style: TextStyle(color: Color(0xFF9A8C9B)),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _showAddHabitSheet(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add First Habit'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColorScheme.primaryGold,
                      foregroundColor: const Color(0xFF130D1B),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              // ── Header Summary Card ──
              _buildOverallStreakCard(habits),
              const SizedBox(height: 20),

              // ── Section Title ──
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ACTIVE HABITS',
                      style: TextStyle(
                        color: Color(0xFFEDB1FF),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '${habits.length} Habits Tracked',
                      style: const TextStyle(
                        color: Color(0xFF9A8C9B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Habit Cards ──
              ...habits.map((habit) => _buildHabitCard(context, habit)),
              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColorScheme.etherealPink),
        ),
        error: (e, _) => Center(
          child: Text('Error loading habits: $e',
              style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildOverallStreakCard(List<HabitEntity> habits) {
    int totalCompletionsToday = 0;
    final now = DateTime.now();
    for (final h in habits) {
      if (h.isCompletedOn(now)) totalCompletionsToday++;
    }

    final bestStreak = habits.fold<int>(
      0,
      (max, h) => h.currentStreak > max ? h.currentStreak : max,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9D50BB).withOpacity(0.3),
            const Color(0xFF6E48AA).withOpacity(0.18),
            const Color(0xFF1E152C).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEDB1FF).withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statColumn(
            'TODAY',
            '$totalCompletionsToday / ${habits.length}',
            Icons.done_all_rounded,
            const Color(0xFF4CAF76),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          _statColumn(
            'BEST STREAK',
            '$bestStreak Days',
            Icons.local_fire_department_rounded,
            const Color(0xFFFF7E67),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          _statColumn(
            'TOTAL HABITS',
            '${habits.length}',
            Icons.auto_awesome_rounded,
            AppColorScheme.primaryGold,
          ),
        ],
      ),
    );
  }

  Widget _statColumn(
      String label, String value, IconData icon, Color accentColor) {
    return Column(
      children: [
        Icon(icon, size: 20, color: accentColor),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9A8C9B),
            fontSize: 10,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildHabitCard(BuildContext context, HabitEntity habit) {
    final now = DateTime.now();
    final isDoneToday = habit.isCompletedOn(now);
    final color = Color(habit.colorHex);

    // Get last 7 days starting from 6 days ago up to today
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E152C).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDoneToday
              ? color.withOpacity(0.5)
              : const Color(0xFFEDB1FF).withOpacity(0.15),
          width: isDoneToday ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDoneToday
                ? color.withOpacity(0.12)
                : Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon, Title, Streak & Check button
          Row(
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.35)),
                ),
                child: Icon(_mapIcon(habit.iconName), color: color, size: 22),
              ),
              const SizedBox(width: 12),

              // Title and Streak
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 13,
                          color: Color(0xFFFF7E67),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${habit.currentStreak} day streak',
                          style: const TextStyle(
                            color: Color(0xFFFF7E67),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(habit.monthlySuccessRate * 100).round()}% monthly',
                          style: const TextStyle(
                            color: Color(0xFFD1C2D2),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Today's Check Toggle
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(habitControllerProvider.notifier)
                      .toggleHabitDay(habit.id, now);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDoneToday ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDoneToday ? color : color.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isDoneToday ? Icons.check : Icons.radio_button_unchecked,
                    color: isDoneToday ? Colors.white : color,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 7-day Mini Heatmap Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isDone = habit.isCompletedOn(day);
              final isToday = day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
              final dayLabel = DateFormat('E').format(day).substring(0, 1);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref
                      .read(habitControllerProvider.notifier)
                      .toggleHabitDay(habit.id, day);
                },
                child: Column(
                  children: [
                    Text(
                      dayLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isToday ? Colors.white : const Color(0xFF9A8C9B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDone
                            ? color
                            : const Color(0xFF281C3B).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: Colors.white, width: 1.5)
                            : null,
                      ),
                      child: isDone
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    int selectedColor = 0xFFF5C34A;
    String selectedIcon = 'favorite';

    const colorOptions = [
      0xFFF5C34A, // Gold
      0xFF9D50BB, // Amethyst
      0xFF56CCF2, // Water Cyan
      0xFF4CAF76, // Emerald
      0xFFFF7E67, // Coral Rose
      0xFFE91E63, // Berry Pink
    ];

    const iconOptions = [
      'favorite',
      'water_drop',
      'self_improvement',
      'directions_walk',
      'auto_stories',
      'fitness_center',
      'nightlight',
      'alarm',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1328),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Create New Habit Ritual',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'e.g. 10 Min Morning Stretch',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      labelText: 'Habit Title',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Why this habit matters to you...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      labelText: 'Motivation / Description (optional)',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Color Picker Row
                  const Text(
                    'Theme Accent Color',
                    style: TextStyle(
                      color: Color(0xFFD1C2D2),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: colorOptions.map((c) {
                      final isSelected = selectedColor == c;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedColor = c),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Color(c),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Color(c).withOpacity(0.5),
                                      blurRadius: 10,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Icon Picker Row
                  const Text(
                    'Icon Badge',
                    style: TextStyle(
                      color: Color(0xFFD1C2D2),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: iconOptions.map((ic) {
                      final isSelected = selectedIcon == ic;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedIcon = ic),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(selectedColor).withOpacity(0.25)
                                : const Color(0xFF281C3B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Color(selectedColor)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Icon(
                            _mapIcon(ic),
                            color: isSelected
                                ? Color(selectedColor)
                                : const Color(0xFFD1C2D2),
                            size: 20,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  FilledButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;

                      await ref
                          .read(habitControllerProvider.notifier)
                          .createHabit(
                            title: title,
                            description: descController.text.trim(),
                            iconName: selectedIcon,
                            colorHex: selectedColor,
                          );

                      if (context.mounted) {
                        Navigator.pop(ctx);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(selectedColor),
                      foregroundColor: const Color(0xFF130D1B),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Save Habit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _mapIcon(String name) {
    switch (name) {
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'self_improvement':
        return Icons.self_improvement_rounded;
      case 'directions_walk':
        return Icons.directions_walk_rounded;
      case 'auto_stories':
        return Icons.auto_stories_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'nightlight':
        return Icons.nightlight_round;
      case 'alarm':
        return Icons.alarm_rounded;
      case 'favorite':
      default:
        return Icons.favorite_rounded;
    }
  }
}
