import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:princes/app/router.dart';
import 'package:princes/app/theme/color_scheme.dart';

/// Navigation Shell hosting the persistent, glassmorphic bottom bar.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: const Color(0xFF130D1B),
      body: widget.navigationShell,
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1328).withOpacity(0.85),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFEDB1FF).withOpacity(0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    selectedIndex: currentIndex,
                    icon: Icons.dashboard_rounded,
                    label: 'Routines',
                  ),
                  _buildNavItem(
                    index: 1,
                    selectedIndex: currentIndex,
                    icon: Icons.local_fire_department_rounded,
                    label: 'Habits',
                  ),
                  // Center Floating Action Button for Quick Creation
                  _buildCenterFab(context),
                  _buildNavItem(
                    index: 2,
                    selectedIndex: currentIndex,
                    icon: Icons.timer_rounded,
                    label: 'Focus',
                  ),
                  _buildNavItem(
                    index: 3,
                    selectedIndex: currentIndex,
                    icon: Icons.insights_rounded,
                    label: 'Insights',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int selectedIndex,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF9D50BB).withOpacity(0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppColorScheme.primaryGold
                  : const Color(0xFF9A8C9B),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF9A8C9B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterFab(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        context.push(AppRoutes.taskCreate);
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFF5C34A), Color(0xFFE8915A)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColorScheme.primaryGold.withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Color(0xFF130D1B),
          size: 28,
        ),
      ),
    );
  }
}
