import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:princes/app/router.dart';
import 'package:princes/app/theme/color_scheme.dart';
import '../../domain/entities/task_entity.dart';
import '../controllers/task_controller.dart';

/// Task creation and editing screen with quick time presets & alarm hub.
class TaskEditorScreen extends ConsumerStatefulWidget {
  const TaskEditorScreen({super.key, this.taskId});

  final String? taskId;

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  static const _uuid = Uuid();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskCategory _category = TaskCategory.personal;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueTime;
  bool _hasAlarm = false;
  DateTime? _alarmTime;
  RecurrenceType _recurrence = RecurrenceType.none;
  List<int> _customDays = [];
  List<SubtaskEntity> _subtasks = [];

  bool _isEditing = false;
  TaskEntity? _existingTask;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _isEditing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadTask());
    } else {
      final now = DateTime.now();
      _dueTime = DateTime(now.year, now.month, now.day, now.hour + 1);
      _alarmTime = _dueTime;
    }
  }

  Future<void> _loadTask() async {
    final repo = ref.read(taskRepositoryProvider);
    final task = await repo.getTaskById(widget.taskId!);
    if (task != null && mounted) {
      setState(() {
        _existingTask = task;
        _titleController.text = task.title;
        _descriptionController.text = task.description;
        _category = task.category;
        _priority = task.priority;
        _dueTime = task.dueTime;
        _hasAlarm = task.hasAlarm;
        _alarmTime = task.alarmTime ?? task.dueTime;
        _recurrence = task.recurrenceType;
        _customDays = List.from(task.customDays);
        _subtasks = List.from(task.subtasks);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130D1B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Routine' : 'New Routine Ritual',
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFFF8A80)),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Title Input ──
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Routine Title',
                labelStyle: TextStyle(color: Color(0xFFD1C2D2)),
                hintText: 'e.g. Morning Meditation & Green Tea',
                hintStyle: TextStyle(color: Colors.white24),
                prefixIcon: Icon(Icons.auto_awesome_rounded,
                    color: AppColorScheme.primaryGold),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Description Input ──
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description & Notes (optional)',
                labelStyle: TextStyle(color: Color(0xFFD1C2D2)),
                hintText: 'Add morning routine details, intentions...',
                hintStyle: TextStyle(color: Colors.white24),
                prefixIcon:
                    Icon(Icons.notes_rounded, color: Color(0xFFEDB1FF)),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // ── Category Selector ──
            const Text(
              'CATEGORY',
              style: TextStyle(
                color: Color(0xFFEDB1FF),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: TaskCategory.values.map((cat) {
                final isSelected = _category == cat;
                final color = _categoryColor(cat);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.25)
                            : const Color(0xFF1E152C),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : const Color(0xFFEDB1FF).withOpacity(0.12),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(_categoryIcon(cat),
                              color: isSelected ? color : const Color(0xFF9A8C9B),
                              size: 20),
                          const SizedBox(height: 4),
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF9A8C9B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Priority Selector ──
            const Text(
              'PRIORITY LEVEL',
              style: TextStyle(
                color: Color(0xFFEDB1FF),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: TaskPriority.values.map((p) {
                final isSelected = _priority == p;
                final color = _priorityColor(p);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.25)
                            : const Color(0xFF1E152C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : const Color(0xFFEDB1FF).withOpacity(0.12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_priorityIcon(p),
                              size: 16,
                              color: isSelected ? color : const Color(0xFF9A8C9B)),
                          const SizedBox(width: 6),
                          Text(
                            p.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.white : const Color(0xFF9A8C9B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Time & Quick Presets ──
            const Text(
              'SCHEDULE & DUE TIME',
              style: TextStyle(
                color: Color(0xFFEDB1FF),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            // Quick preset chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _presetChip('Morning (8:00 AM)', 8, 0),
                  const SizedBox(width: 8),
                  _presetChip('Noon (12:30 PM)', 12, 30),
                  const SizedBox(width: 8),
                  _presetChip('Evening (6:00 PM)', 18, 0),
                  const SizedBox(width: 8),
                  _presetChip('Night (9:00 PM)', 21, 0),
                ],
              ),
            ),
            const SizedBox(height: 10),

            ListTile(
              leading: const Icon(Icons.calendar_today_rounded,
                  color: AppColorScheme.primaryGold),
              title: const Text('Custom Date & Time',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(
                _dueTime != null
                    ? '${_dueTime!.day}/${_dueTime!.month}/${_dueTime!.year} at ${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}'
                    : 'Not set',
                style: const TextStyle(color: Color(0xFFD1C2D2)),
              ),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9A8C9B)),
              onTap: _pickDateTime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                    color: const Color(0xFFEDB1FF).withOpacity(0.15)),
              ),
              tileColor: const Color(0xFF1E152C),
            ),
            const SizedBox(height: 24),

            // ── Alarm Section (Hero Feature) ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _hasAlarm
                    ? const Color(0xFF9D50BB).withOpacity(0.2)
                    : const Color(0xFF1E152C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _hasAlarm
                      ? AppColorScheme.primaryGold.withOpacity(0.6)
                      : const Color(0xFFEDB1FF).withOpacity(0.15),
                  width: _hasAlarm ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _hasAlarm
                            ? Icons.alarm_on_rounded
                            : Icons.alarm_off_outlined,
                        color: _hasAlarm
                            ? AppColorScheme.primaryGold
                            : const Color(0xFF9A8C9B),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Wake-Up Alarm & Ringing Screen',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Full-screen wake-up clock with royal quotes',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _hasAlarm,
                        activeColor: AppColorScheme.primaryGold,
                        onChanged: (value) {
                          setState(() {
                            _hasAlarm = value;
                            if (_hasAlarm && _alarmTime == null) {
                              _alarmTime = _dueTime ?? DateTime.now();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (_hasAlarm) ...[
                    const Divider(color: Color(0x1AFFFFFF), height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _alarmTime != null
                              ? 'Alarm Set: ${_alarmTime!.hour.toString().padLeft(2, '0')}:${_alarmTime!.minute.toString().padLeft(2, '0')}'
                              : 'Set alarm time',
                          style: const TextStyle(
                            color: AppColorScheme.primaryGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: _pickAlarmTime,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF281C3B),
                            foregroundColor: const Color(0xFFEDB1FF),
                          ),
                          child: const Text('Change Time'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Subtasks & Checklist ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SUBTASKS & STEPS',
                  style: TextStyle(
                    color: Color(0xFFEDB1FF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Step'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColorScheme.primaryGold,
                  ),
                ),
              ],
            ),
            ..._subtasks.asMap().entries.map((entry) {
              final index = entry.key;
              final subtask = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E152C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: subtask.isCompleted,
                      activeColor: const Color(0xFF4CAF76),
                      onChanged: (value) {
                        setState(() {
                          _subtasks[index] = subtask.copyWith(
                            isCompleted: value ?? false,
                          );
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        subtask.title,
                        style: TextStyle(
                          decoration: subtask.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: subtask.isCompleted
                              ? Colors.white38
                              : Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.white38),
                      onPressed: () {
                        setState(() => _subtasks.removeAt(index));
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),

            // ── Save Button ──
            FilledButton.icon(
              onPressed: _saveTask,
              icon: Icon(_isEditing ? Icons.save_rounded : Icons.add_rounded),
              label: Text(_isEditing ? 'Save Changes' : 'Create Routine'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColorScheme.primaryGold,
                foregroundColor: const Color(0xFF130D1B),
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _presetChip(String label, int hour, int minute) {
    final now = DateTime.now();
    final isSelected = _dueTime != null &&
        _dueTime!.hour == hour &&
        _dueTime!.minute == minute;

    return GestureDetector(
      onTap: () {
        setState(() {
          _dueTime = DateTime(now.year, now.month, now.day, hour, minute);
          if (_hasAlarm) _alarmTime = _dueTime;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColorScheme.primaryGold.withOpacity(0.2)
              : const Color(0xFF1E152C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColorScheme.primaryGold
                : const Color(0xFFEDB1FF).withOpacity(0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColorScheme.primaryGold : const Color(0xFFD1C2D2),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueTime ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueTime ?? now),
    );
    if (time == null || !mounted) return;

    setState(() {
      _dueTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (_hasAlarm && _alarmTime == null) {
        _alarmTime = _dueTime;
      }
    });
  }

  Future<void> _pickAlarmTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _alarmTime ?? _dueTime ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_alarmTime ?? _dueTime ?? now),
    );
    if (time == null || !mounted) return;

    setState(() {
      _alarmTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _addSubtask() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1328),
        title: const Text('Add Routine Step',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Step title...',
            hintStyle: TextStyle(color: Colors.white38),
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) {
            _confirmAddSubtask(controller.text);
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          FilledButton(
            onPressed: () {
              _confirmAddSubtask(controller.text);
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColorScheme.primaryGold,
              foregroundColor: const Color(0xFF130D1B),
            ),
            child: const Text('Add Step'),
          ),
        ],
      ),
    );
  }

  void _confirmAddSubtask(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      _subtasks.add(SubtaskEntity(
        id: _uuid.v4(),
        title: title.trim(),
      ));
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(taskControllerProvider.notifier);

    if (_isEditing && _existingTask != null) {
      await controller.updateTask(_existingTask!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        priority: _priority,
        dueTime: _dueTime,
        hasAlarm: _hasAlarm,
        alarmTime: _alarmTime ?? _dueTime,
        recurrenceType: _recurrence,
        customDays: _customDays,
        subtasks: _subtasks,
      ));
    } else {
      await controller.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        priority: _priority,
        dueTime: _dueTime,
        hasAlarm: _hasAlarm,
        alarmTime: _alarmTime ?? _dueTime,
        recurrenceType: _recurrence,
        customDays: _customDays,
        subtasks: _subtasks,
      );
    }

    if (mounted) context.pop();
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1328),
        title: const Text('Delete Routine?', style: TextStyle(color: Colors.white)),
        content: const Text('This action cannot be undone.',
            style: TextStyle(color: Color(0xFFD1C2D2))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(taskControllerProvider.notifier)
          .deleteTask(widget.taskId!);
      if (mounted) context.pop();
    }
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
      case TaskPriority.low:
        return AppColorScheme.priorityLow;
      case TaskPriority.medium:
        return AppColorScheme.priorityMedium;
      case TaskPriority.high:
        return AppColorScheme.priorityHigh;
    }
  }

  IconData _categoryIcon(TaskCategory cat) {
    switch (cat) {
      case TaskCategory.work:
        return Icons.work_rounded;
      case TaskCategory.health:
        return Icons.favorite_rounded;
      case TaskCategory.personal:
        return Icons.person_rounded;
    }
  }

  IconData _priorityIcon(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
    }
  }
}
