import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:princes/app/theme/color_scheme.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../domain/entities/task_entity.dart';

/// A polished, glassmorphic task card with swipe gestures and priority accents.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    this.onDelete,
  });

  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;
    final isOverdue = !isDone &&
        task.dueTime != null &&
        task.dueTime!.isBefore(DateTime.now());

    final priorityColor = _priorityColor(task.priority);

    final cardContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E152C).withOpacity(isDone ? 0.4 : 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone
              ? Colors.white.withOpacity(0.06)
              : (isOverdue
                  ? const Color(0xFFFF5252).withOpacity(0.5)
                  : const Color(0xFFEDB1FF).withOpacity(0.16)),
          width: isOverdue ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Priority Accent Bar ──
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: isDone
                      ? priorityColor.withOpacity(0.3)
                      : priorityColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),

              // ── Main Card Body ──
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                    child: Row(
                      children: [
                        // Completion Toggle Button
                        _CompletionCheckbox(
                          isCompleted: isDone,
                          priority: task.priority,
                          onToggle: () {
                            HapticFeedback.lightImpact();
                            onToggle();
                          },
                        ),
                        const SizedBox(width: 14),

                        // Task Metadata
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title & Overdue tag
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: isDone
                                            ? Colors.white.withOpacity(0.4)
                                            : Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isOverdue)
                                    Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5252)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'OVERDUE',
                                        style: TextStyle(
                                          color: Color(0xFFFF5252),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Meta badges row
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  // Due time
                                  if (task.dueTime != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 13,
                                          color: isOverdue
                                              ? const Color(0xFFFF8A80)
                                              : const Color(0xFFD1C2D2),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          task.dueTime!.formattedTime,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isOverdue
                                                ? const Color(0xFFFF8A80)
                                                : const Color(0xFFD1C2D2),
                                          ),
                                        ),
                                      ],
                                    ),

                                  // Alarm badge
                                  if (task.hasAlarm)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColorScheme.primaryGold
                                            .withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColorScheme.primaryGold
                                              .withOpacity(0.35),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.alarm_on_rounded,
                                            size: 11,
                                            color: AppColorScheme.primaryGold,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            task.alarmTime != null
                                                ? '${task.alarmTime!.hour.toString().padLeft(2, '0')}:${task.alarmTime!.minute.toString().padLeft(2, '0')}'
                                                : 'Alarm',
                                            style: const TextStyle(
                                              color: AppColorScheme.primaryGold,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Category Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _categoryColor(task.category)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      task.category.label,
                                      style: TextStyle(
                                        color: _categoryColor(task.category),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  // Subtask progress count
                                  if (task.subtasks.isNotEmpty)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.checklist_rounded,
                                          size: 13,
                                          color: Color(0xFFD1C2D2),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFFD1C2D2),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),

                              // Subtask mini progress bar
                              if (task.subtasks.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: task.subtaskProgress,
                                    minHeight: 3.5,
                                    backgroundColor: Colors.white12,
                                    color: task.subtaskProgress == 1.0
                                        ? const Color(0xFF4CAF76)
                                        : AppColorScheme.etherealPink,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF9A8C9B),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Swipeable dismissible wrapper
    return Dismissible(
      key: Key('task_${task.id}'),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF76).withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              'Complete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5252).withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_forever_rounded, color: Colors.white, size: 26),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
          return false;
        } else if (direction == DismissDirection.endToStart) {
          if (onDelete != null) {
            onDelete!();
          }
          return false;
        }
        return false;
      },
      child: cardContent,
    );
  }

  Color _categoryColor(TaskCategory cat) {
    switch (cat) {
      case TaskCategory.work:
        return AppColorScheme.categoryWork;
      case TaskCategory.health:
        return AppColorScheme.categoryHealth;
      case TaskCategory.personal:
        return AppColorScheme.categoryPersonal;
    }
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return AppColorScheme.priorityHigh;
      case TaskPriority.medium:
        return AppColorScheme.priorityMedium;
      case TaskPriority.low:
        return AppColorScheme.priorityLow;
    }
  }
}

class _CompletionCheckbox extends StatelessWidget {
  const _CompletionCheckbox({
    required this.isCompleted,
    required this.priority,
    required this.onToggle,
  });

  final bool isCompleted;
  final TaskPriority priority;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF4CAF76)
              : Colors.transparent,
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF4CAF76)
                : const Color(0xFFEDB1FF).withOpacity(0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF76).withOpacity(0.4),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: isCompleted
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}
