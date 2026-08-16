import 'package:flutter/material.dart';

import '../../domain/entities/task_entity.dart';

/// Inline subtask checklist widget (FR-1.3).
class SubtaskChecklist extends StatelessWidget {
  const SubtaskChecklist({
    super.key,
    required this.subtasks,
    required this.onToggle,
  });

  final List<SubtaskEntity> subtasks;
  final void Function(String subtaskId) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (subtasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.checklist_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '${subtasks.where((s) => s.isCompleted).length}/${subtasks.length} completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ...subtasks.map((subtask) => InkWell(
              onTap: () => onToggle(subtask.id),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: subtask.isCompleted
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: subtask.isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                          width: 1.5,
                        ),
                        borderRadius:
                            BorderRadius.circular(5),
                      ),
                      child: subtask.isCompleted
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        subtask.title,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(
                          decoration: subtask.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: subtask.isCompleted
                              ? theme
                                  .colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
