import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:princes/app/theme/color_scheme.dart';

/// Animated daily progress hero widget with multi-stats and streak indicator.
class DailyProgressRing extends StatelessWidget {
  const DailyProgressRing({
    super.key,
    required this.total,
    required this.completed,
    this.streakDays = 3,
  });

  final int total;
  final int completed;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    final isAllDone = total > 0 && completed == total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9D50BB).withOpacity(0.25),
            const Color(0xFF6E48AA).withOpacity(0.15),
            const Color(0xFF1E152C).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAllDone
              ? AppColorScheme.primaryGold.withOpacity(0.5)
              : const Color(0xFFEDB1FF).withOpacity(0.2),
          width: isAllDone ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isAllDone
                ? AppColorScheme.primaryGold.withOpacity(0.18)
                : const Color(0xFF9D50BB).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Circular Progress Ring ──
          CircularPercentIndicator(
            radius: 42,
            lineWidth: 8,
            percent: percent,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  total > 0 ? '${(percent * 100).round()}%' : '0%',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (isAllDone)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColorScheme.primaryGold,
                  ),
              ],
            ),
            linearGradient: const LinearGradient(
              colors: [
                Color(0xFFFFDF79),
                Color(0xFFF5C34A),
                Color(0xFFE8915A),
              ],
            ),
            backgroundColor: const Color(0x22FFFFFF),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1000,
          ),
          const SizedBox(width: 18),

          // ── Stats Info & Streak ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _greetingText(),
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                    // Streak Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7E67).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFF7E67).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 13,
                            color: Color(0xFFFF7E67),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$streakDays Days',
                            style: const TextStyle(
                              color: Color(0xFFFF7E67),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  total > 0
                      ? '$completed of $total daily milestones completed'
                      : 'No tasks scheduled yet today',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 8),

                // Linear mini bar breakdown
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 5,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isAllDone
                          ? AppColorScheme.primaryGold
                          : const Color(0xFFEDB1FF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }
}
