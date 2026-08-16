import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:princes/app/theme/color_scheme.dart';
import 'package:princes/features/focus/presentation/controllers/focus_controller.dart';

/// Serene Focus Timer & Pomodoro screen with ambient sound player.
class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusState = ref.watch(focusControllerProvider);
    final controller = ref.read(focusControllerProvider.notifier);

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
                'Focus Sanctuary',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              Text(
                'Deep work, clear mind & royal poise',
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // ── Mode Switcher Segment ──
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E152C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEDB1FF).withOpacity(0.15),
              ),
            ),
            child: Row(
              children: FocusMode.values.map((mode) {
                final isSelected = focusState.mode == mode;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.setMode(mode);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        mode.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF9A8C9B),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 36),

          // ── Circular Timer Dial ──
          Center(
            child: CircularPercentIndicator(
              radius: 120,
              lineWidth: 12,
              percent: focusState.progress,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    focusState.formattedTime,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 54,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    focusState.isRunning ? 'FOCUSING...' : 'PAUSED',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: focusState.isRunning
                          ? AppColorScheme.primaryGold
                          : const Color(0xFF9A8C9B),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              linearGradient: const LinearGradient(
                colors: [
                  Color(0xFFF5C34A),
                  Color(0xFFEDB1FF),
                  Color(0xFF9D50BB),
                ],
              ),
              backgroundColor: const Color(0xFF281C3B).withOpacity(0.6),
              circularStrokeCap: CircularStrokeCap.round,
              animation: false,
            ),
          ),

          const SizedBox(height: 36),

          // ── Primary Action Controls ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset Button
              IconButton.filledTonal(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.reset();
                },
                icon: const Icon(Icons.refresh_rounded),
                iconSize: 24,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF281C3B),
                  foregroundColor: const Color(0xFFD1C2D2),
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(width: 24),

              // Start / Pause Big Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  controller.toggleStartPause();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF5C34A), Color(0xFFE8915A)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColorScheme.primaryGold.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        focusState.isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: const Color(0xFF130D1B),
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        focusState.isRunning ? 'PAUSE' : 'START FOCUS',
                        style: const TextStyle(
                          color: Color(0xFF130D1B),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 36),

          // ── Daily Stats Summary Cards ──
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  'COMPLETED',
                  '${focusState.completedSessions} Sessions',
                  Icons.check_circle_outline_rounded,
                  const Color(0xFF4CAF76),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildStatTile(
                  'TOTAL TIME',
                  '${focusState.totalMinutesFocused} Minutes',
                  Icons.timer_outlined,
                  AppColorScheme.primaryGold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Ambient Soundscapes Selector ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E152C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFEDB1FF).withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.headphones_rounded,
                      size: 18,
                      color: AppColorScheme.etherealPink,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'AMBIENT SOUNDSCAPES',
                      style: TextStyle(
                        color: AppColorScheme.etherealPink,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Off',
                    'Soft Rain 🌧️',
                    'Forest Birds 🌲',
                    'Ocean Waves 🌊',
                    'White Noise 📻',
                  ].map((sound) {
                    final isSelected = focusState.ambientSound == sound;
                    return ChoiceChip(
                      label: Text(sound),
                      selected: isSelected,
                      selectedColor: const Color(0xFF9D50BB).withOpacity(0.4),
                      backgroundColor: const Color(0xFF281C3B),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFFD1C2D2),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        HapticFeedback.lightImpact();
                        controller.setAmbientSound(sound);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildStatTile(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E152C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEDB1FF).withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
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
      ),
    );
  }
}
