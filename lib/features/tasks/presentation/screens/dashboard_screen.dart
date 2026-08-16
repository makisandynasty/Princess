import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:princes/app/router.dart';
import 'package:princes/app/theme/color_scheme.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/confetti_celebration.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../quotes/presentation/widgets/quote_card.dart';
import '../../domain/entities/task_entity.dart';
import '../controllers/task_controller.dart';
import '../widgets/daily_progress_ring.dart';
import '../widgets/task_card.dart';

/// Redesigned Royal Dashboard Screen with Date Carousel, Quotes, and Streaks.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  bool _isSearchVisible = false;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final stats = ref.watch(dailyStatsProvider);
    final authState = ref.watch(authControllerProvider);

    final isAllCompleted = stats.total > 0 && stats.completed == stats.total;

    return Scaffold(
      backgroundColor: const Color(0xFF130D1B),
      body: ConfettiCelebration(
        trigger: isAllCompleted,
        child: RefreshIndicator(
          color: AppColorScheme.primaryGold,
          backgroundColor: const Color(0xFF1E152C),
          onRefresh: () async {
            ref.invalidate(todayTasksProvider);
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. Royal App Bar Header ──
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top profile & actions row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // Glowing crown avatar
                                Container(
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFE9C349),
                                        Color(0xFFEDB1FF),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE9C349)
                                            .withOpacity(0.35),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: const Color(0xFF1C1328),
                                    child: Text(
                                      authState.displayName.isNotEmpty
                                          ? authState.displayName[0].toUpperCase()
                                          : 'P',
                                      style: const TextStyle(
                                        fontFamily: 'Playfair Display',
                                        color: AppColorScheme.primaryGold,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Princess ${authState.displayName}',
                                      style: const TextStyle(
                                        fontFamily: 'Playfair Display',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                                      style: const TextStyle(
                                        color: Color(0xFFD1C2D2),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isSearchVisible
                                        ? Icons.close_rounded
                                        : Icons.search_rounded,
                                    color: const Color(0xFFEDB1FF),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isSearchVisible = !_isSearchVisible;
                                      if (!_isSearchVisible) _searchQuery = '';
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.settings_suggest_rounded,
                                    color: Color(0xFFEDB1FF),
                                  ),
                                  onPressed: () =>
                                      context.push(AppRoutes.settings),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Search Bar
                        if (_isSearchVisible) ...[
                          const SizedBox(height: 12),
                          TextField(
                            autofocus: true,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (val) =>
                                setState(() => _searchQuery = val.trim().toLowerCase()),
                            decoration: InputDecoration(
                              hintText: 'Search tasks, routines, subtasks...',
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.4)),
                              prefixIcon: const Icon(Icons.search_rounded,
                                  color: AppColorScheme.etherealPink),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // ── 2. Horizontal Date Strip Carousel ──
              SliverToBoxAdapter(
                child: _buildDateCarousel(),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── 3. Daily Progress Hero ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DailyProgressRing(
                    total: stats.total,
                    completed: stats.completed,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // ── 4. Quick Action Chips Row ──
              SliverToBoxAdapter(
                child: _buildQuickActionChips(context),
              ),

              // ── 5. Motivational Daily Quote Card ──
              const SliverToBoxAdapter(
                child: QuoteCard(),
              ),

              // ── 6. Task List Sections ──
              tasksAsync.when(
                data: (tasks) {
                  final filtered = _searchQuery.isEmpty
                      ? tasks
                      : tasks.where((t) {
                          return t.title.toLowerCase().contains(_searchQuery) ||
                              t.description.toLowerCase().contains(_searchQuery);
                        }).toList();

                  return _buildTaskSections(context, ref, filtered);
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColorScheme.primaryGold,
                    ),
                  ),
                ),
                error: (error, _) => SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Error loading tasks: $error',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Bottom spacing for glassmorphic nav bar
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCarousel() {
    final now = DateTime.now();
    // 7 days window (3 days past, today, 3 days future)
    final days = List.generate(7, (i) => now.subtract(Duration(days: 3 - i)));

    return SizedBox(
      height: 78,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;
          final isToday = date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedDate = date;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
                      )
                    : null,
                color: isSelected
                    ? null
                    : const Color(0xFF1E152C).withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColorScheme.primaryGold
                      : (isToday
                          ? const Color(0xFFEDB1FF).withOpacity(0.4)
                          : Colors.white.withOpacity(0.08)),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? AppColorScheme.primaryGold
                          : const Color(0xFF9A8C9B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFFD1C2D2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionChips(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _quickChip(
              label: 'New Routine',
              icon: Icons.add_task_rounded,
              color: AppColorScheme.primaryGold,
              onTap: () => context.push(AppRoutes.taskCreate),
            ),
            const SizedBox(width: 8),
            _quickChip(
              label: 'Focus Timer',
              icon: Icons.timer_outlined,
              color: const Color(0xFF56CCF2),
              onTap: () => context.push(AppRoutes.focus),
            ),
            const SizedBox(width: 8),
            _quickChip(
              label: 'Habit Ritual',
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFFF7E67),
              onTap: () => context.push(AppRoutes.habits),
            ),
            const SizedBox(width: 8),
            _quickChip(
              label: 'Alarm Hub',
              icon: Icons.alarm_rounded,
              color: const Color(0xFFEDB1FF),
              onTap: () => context.push(AppRoutes.alarmFullscreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSections(
    BuildContext context,
    WidgetRef ref,
    List<TaskEntity> tasks,
  ) {
    final activeTasks = tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = tasks.where((t) => t.isCompleted).toList();

    final morning =
        activeTasks.where((t) => t.dueTime?.daySegment == 'Morning').toList();
    final afternoon =
        activeTasks.where((t) => t.dueTime?.daySegment == 'Afternoon').toList();
    final evening =
        activeTasks.where((t) => t.dueTime?.daySegment == 'Evening').toList();

    // Tasks without specific segments
    final anytime = activeTasks
        .where((t) =>
            t.dueTime == null ||
            (t.dueTime?.daySegment != 'Morning' &&
                t.dueTime?.daySegment != 'Afternoon' &&
                t.dueTime?.daySegment != 'Evening'))
        .toList();

    if (tasks.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E152C).withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColorScheme.primaryGold.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 40,
                  color: AppColorScheme.primaryGold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'A Clear Canvas Awaits You 👑',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'No routines scheduled for this day. Tap + to craft your schedule.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9A8C9B), fontSize: 13),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.taskCreate),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create New Routine'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColorScheme.primaryGold,
                  foregroundColor: const Color(0xFF130D1B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        if (morning.isNotEmpty) ...[
          _sectionHeader(context, '☀️ Morning Priorities', morning.length),
          ...morning.map((t) => _buildTaskCard(context, ref, t)),
        ],
        if (afternoon.isNotEmpty) ...[
          _sectionHeader(context, '🌤️ Afternoon Focus', afternoon.length),
          ...afternoon.map((t) => _buildTaskCard(context, ref, t)),
        ],
        if (evening.isNotEmpty) ...[
          _sectionHeader(context, '🌙 Evening Wind-down', evening.length),
          ...evening.map((t) => _buildTaskCard(context, ref, t)),
        ],
        if (anytime.isNotEmpty) ...[
          _sectionHeader(context, '📌 Flexible Priorities', anytime.length),
          ...anytime.map((t) => _buildTaskCard(context, ref, t)),
        ],
        if (completedTasks.isNotEmpty) ...[
          _sectionHeader(context, '✅ Accomplished', completedTasks.length),
          ...completedTasks.map((t) => _buildTaskCard(context, ref, t)),
        ],
      ]),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, TaskEntity t) {
    return TaskCard(
      task: t,
      onTap: () => context.push(
        '${AppRoutes.taskEditor}?id=${t.id}',
      ),
      onToggle: () =>
          ref.read(taskControllerProvider.notifier).toggleCompletion(t.id),
      onDelete: () =>
          ref.read(taskControllerProvider.notifier).deleteTask(t.id),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF9D50BB).withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFEDB1FF).withOpacity(0.3),
              ),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Color(0xFFEDB1FF),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
