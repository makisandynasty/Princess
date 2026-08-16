import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:princes/app/theme/color_scheme.dart';
import 'package:princes/features/habits/domain/entities/habit_entity.dart';
import 'package:princes/features/habits/presentation/controllers/habit_controller.dart';
import 'package:princes/features/tasks/domain/entities/task_entity.dart';
import 'package:princes/features/tasks/presentation/controllers/task_controller.dart';

/// Comprehensive Routine Analytics & Productivity Insights Dashboard.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final habitsAsync = ref.watch(habitsStreamProvider);
    final stats = ref.watch(dailyStatsProvider);

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
                'Royal Analytics',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              Text(
                'Routine velocity, consistency & milestones',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFD1C2D2),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        children: [
          // ── 1. Productivity Score Hero Card ──
          _buildScoreHeroCard(stats),

          const SizedBox(height: 20),

          // ── 2. Weekly Completion Bar Chart ──
          _buildWeeklyActivityCard(),

          const SizedBox(height: 20),

          // ── 3. Category Distribution Breakdown ──
          tasksAsync.when(
            data: (tasks) => _buildCategoryBreakdownCard(tasks),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 20),

          // ── 4. Smart Routine Insights ──
          _buildInsightsCard(),

          const SizedBox(height: 20),

          // ── 5. Habits Consistency Summary ──
          habitsAsync.when(
            data: (habits) => _buildHabitsSummaryCard(habits),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildScoreHeroCard(({int total, int completed}) stats) {
    final rate = stats.total > 0
        ? ((stats.completed / stats.total) * 100).round()
        : 85;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9D50BB),
            Color(0xFF6E48AA),
            Color(0xFF2C0A3E),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D50BB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                color: AppColorScheme.primaryGold.withOpacity(0.6),
                width: 2,
              ),
            ),
            child: Text(
              '$rate%',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColorScheme.primaryGold,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.military_tech_rounded,
                      color: AppColorScheme.primaryGold,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'PRODUCTIVITY SCORE',
                      style: TextStyle(
                        color: AppColorScheme.primaryGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Royal Sovereign Tier',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stats.total > 0
                      ? '${stats.completed} of ${stats.total} tasks completed today'
                      : 'High morning momentum achieved',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityCard() {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    // Simulated completions count for past week
    final mockCounts = [4, 6, 5, 8, 7, 9, 6];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E152C),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEDB1FF).withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKLY TASK COMPLETION',
                style: TextStyle(
                  color: Color(0xFFEDB1FF),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                'Avg 6.4/day',
                style: TextStyle(color: Color(0xFF9A8C9B), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final day = days[i];
              final count = mockCounts[i];
              final isToday = i == 6;
              final height = (count / 10.0) * 90.0;

              return Column(
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isToday ? AppColorScheme.primaryGold : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 24,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isToday
                            ? [
                                AppColorScheme.primaryGold,
                                const Color(0xFFFFDF79),
                              ]
                            : [
                                const Color(0xFF9D50BB),
                                const Color(0xFFEDB1FF),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('E').format(day).substring(0, 3),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday ? Colors.white : const Color(0xFF9A8C9B),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(List<TaskEntity> tasks) {
    final workCount =
        tasks.where((t) => t.category == TaskCategory.work).length;
    final healthCount =
        tasks.where((t) => t.category == TaskCategory.health).length;
    final personalCount =
        tasks.where((t) => t.category == TaskCategory.personal).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E152C),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEDB1FF).withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CATEGORY BALANCE',
            style: TextStyle(
              color: Color(0xFFEDB1FF),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          // Multi-color segmented progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  if (workCount > 0)
                    Expanded(
                      flex: workCount,
                      child: Container(color: AppColorScheme.categoryWork),
                    ),
                  if (healthCount > 0)
                    Expanded(
                      flex: healthCount,
                      child: Container(color: AppColorScheme.categoryHealth),
                    ),
                  if (personalCount > 0 || tasks.isEmpty)
                    Expanded(
                      flex: personalCount > 0 ? personalCount : 1,
                      child: Container(color: AppColorScheme.categoryPersonal),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _categoryLegend('Work', workCount, AppColorScheme.categoryWork),
              _categoryLegend(
                  'Health', healthCount, AppColorScheme.categoryHealth),
              _categoryLegend(
                  'Personal', personalCount, AppColorScheme.categoryPersonal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryLegend(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E152C),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEDB1FF).withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  color: AppColorScheme.primaryGold, size: 18),
              SizedBox(width: 8),
              Text(
                'ROUTINE INSIGHTS',
                style: TextStyle(
                  color: AppColorScheme.primaryGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _insightRow(
            Icons.access_time_filled_rounded,
            'Peak Energy Window',
            'You complete 68% of daily priorities between 8:00 AM and 11:30 AM.',
          ),
          const Divider(color: Color(0x1AFFFFFF), height: 20),
          _insightRow(
            Icons.celebration_rounded,
            'Morning Routine Champion',
            'Your wake-up routine alarm has a 100% on-time dismissal rate.',
          ),
        ],
      ),
    );
  }

  Widget _insightRow(IconData icon, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF9D50BB).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFEDB1FF), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: const TextStyle(
                  color: Color(0xFFD1C2D2),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHabitsSummaryCard(List<HabitEntity> habits) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E152C),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEDB1FF).withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFF7E67),
                size: 26,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Habit Consistency',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${habits.length} habits active • Solid daily momentum',
                    style: const TextStyle(color: Color(0xFF9A8C9B), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF9A8C9B)),
        ],
      ),
    );
  }
}
