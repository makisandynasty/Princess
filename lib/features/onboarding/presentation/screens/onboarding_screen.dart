import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:princes/app/router.dart';
import 'package:princes/app/theme/color_scheme.dart';

/// 3-slide royal onboarding carousel for new users.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Welcome, Princess 👑',
      subtitle:
          'Your personal royal sanctuary for wake-up alarms, morning affirmations, and mindful routines.',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFF5C34A),
    ),
    _OnboardingPageData(
      title: 'Flawless Daily Rituals ✨',
      subtitle:
          'Organize priorities by Morning, Afternoon & Evening. Break down big dreams into seamless subtasks.',
      icon: Icons.checklist_rounded,
      color: Color(0xFFEDB1FF),
    ),
    _OnboardingPageData(
      title: 'Habit Streaks & Focus ⏱️',
      subtitle:
          'Build unshakeable daily streaks, enter deep work in the Focus Sanctuary, and track your royal growth.',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFFF7E67),
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('princess_onboarding_completed', true);
    if (mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF130D1B),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF130D1B),
              Color(0xFF1C1328),
              Color(0xFF120B1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Color(0xFFD1C2D2),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final p = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon hero badge
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  p.color.withOpacity(0.3),
                                  const Color(0xFF9D50BB).withOpacity(0.2),
                                ],
                              ),
                              border: Border.all(
                                color: p.color.withOpacity(0.6),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: p.color.withOpacity(0.25),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(p.icon, size: 68, color: p.color),
                          ),
                          const SizedBox(height: 48),

                          // Title
                          Text(
                            p.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Playfair Display',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            p.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.75),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final isSelected = _currentPage == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColorScheme.primaryGold
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 36),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FilledButton(
                  onPressed: isLast
                      ? _completeOnboarding
                      : () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          );
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorScheme.primaryGold,
                    foregroundColor: const Color(0xFF130D1B),
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isLast ? 'Begin Your Journey' : 'Continue',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
