import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../quotes/presentation/controllers/quote_controller.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';
import '../../data/services/alarm_scheduler_service.dart';
import '../../data/services/sound_service.dart';

/// Full-screen alarm display — real ringing, wake-up & buzzing alarm interface.
class AlarmFullscreen extends ConsumerStatefulWidget {
  const AlarmFullscreen({super.key, this.taskId});

  final String? taskId;

  @override
  ConsumerState<AlarmFullscreen> createState() => _AlarmFullscreenState();
}

class _AlarmFullscreenState extends ConsumerState<AlarmFullscreen>
    with TickerProviderStateMixin {
  late Timer _clockTimer;
  late AnimationController _pulseController;
  String _currentTime = '';
  double _dismissProgress = 0.0;
  TaskEntity? _task;

  @override
  void initState() {
    super.initState();

    // Immersive fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _updateTime();
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateTime(),
    );

    // Ensure audio starts looping and buzzing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTask();
      ref.read(soundServiceProvider).startAlarmLoop();
    });
  }

  Future<void> _loadTask() async {
    final effectiveTaskId = widget.taskId ??
        ref.read(alarmSchedulerServiceProvider).ringingTask?.id;
    if (effectiveTaskId != null) {
      final repo = ref.read(taskRepositoryProvider);
      final t = await repo.getTaskById(effectiveTaskId);
      if (mounted) {
        setState(() {
          _task = t;
        });
      }
    }
  }

  @override
  void dispose() {
    ref.read(soundServiceProvider).stop();
    _clockTimer.cancel();
    _pulseController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final quote = ref.watch(todayQuoteProvider);

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C0A3E),
              Color(0xFF4A154B),
              Color(0xFF150024),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 1),

              // ── Pulsing Alarm Bell Indicator ─────────────────────
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE9C349).withOpacity(
                        0.15 + (_pulseController.value * 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE9C349).withOpacity(
                            0.3 * _pulseController.value,
                          ),
                          blurRadius: 30 * _pulseController.value,
                          spreadRadius: 10 * _pulseController.value,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.alarm_on_rounded,
                      size: 48,
                      color: Color(0xFFE9C349),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── Current Time (Hero Display) ───────────────────────
              Text(
                _currentTime,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 76,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getDateString(),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 32),

              // ── Task Title ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      _task?.title ?? 'Wake-Up Routine Alarm',
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_task?.description.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        _task!.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Daily Quote ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  children: [
                    Text(
                      '"${quote.text}"',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withOpacity(0.85),
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '— ${quote.author}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // ── Snooze Button ──────────────────────────────────
              FilledButton.tonalIcon(
                onPressed: _snooze,
                icon: const Icon(Icons.snooze_rounded, color: Colors.white),
                label: Text(
                  'Snooze ${AppConstants.defaultSnoozeDurationMinutes} Minutes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Dismiss Slider ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _buildDismissSlider(size),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissSlider(Size size) {
    final sliderWidth = size.width - 64;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
        ),
      ),
      child: Stack(
        children: [
          // Progress fill
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: sliderWidth * _dismissProgress,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0x66E91E63),
                  Color(0xFFE91E63),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
            ),
          ),

          // Label
          Center(
            child: Text(
              _dismissProgress > 0.8
                  ? 'Release to Stop Alarm'
                  : 'Slide to Turn Off Alarm →',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Draggable thumb
          Positioned(
            left: (_dismissProgress * (sliderWidth - 56))
                .clamp(0.0, sliderWidth - 56),
            top: 4,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dismissProgress += details.delta.dx / (sliderWidth - 56);
                  _dismissProgress = _dismissProgress.clamp(0.0, 1.0);
                });
              },
              onHorizontalDragEnd: (details) {
                if (_dismissProgress > 0.8) {
                  _dismiss();
                } else {
                  setState(() => _dismissProgress = 0.0);
                }
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  color: Color(0xFFE91E63),
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateString() {
    final now = DateTime.now();
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[now.weekday]}, ${months[now.month]} ${now.day}';
  }

  void _snooze() {
    ref.read(alarmSchedulerServiceProvider.notifier).snoozeCurrentAlarm(10);
    Navigator.of(context).pop();
  }

  void _dismiss() {
    ref.read(alarmSchedulerServiceProvider.notifier).dismissCurrentAlarm();
    Navigator.of(context).pop();
  }
}
