import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/alarm/presentation/screens/alarm_fullscreen.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/focus/presentation/screens/focus_screen.dart';
import '../features/habits/presentation/screens/habits_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/photos/presentation/screens/photo_picker_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/tasks/presentation/screens/dashboard_screen.dart';
import '../features/tasks/presentation/screens/task_editor_screen.dart';
import 'widgets/app_shell.dart';

/// Route path constants.
abstract class AppRoutes {
  static const String dashboard = '/';
  static const String habits = '/habits';
  static const String focus = '/focus';
  static const String analytics = '/analytics';
  static const String onboarding = '/onboarding';

  static const String taskEditor = '/task/edit';
  static const String taskCreate = '/task/create';
  static const String alarmFullscreen = '/alarm';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String photoPicker = '/photos/picker';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// GoRouter configuration provider with StatefulShellRoute.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: false,
    routes: [
      // ── Main Shell with 4 Bottom Tabs ───────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Dashboard / Routines
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'dashboard',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardScreen(),
                ),
              ),
            ],
          ),

          // Tab 1: Habits
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.habits,
                name: 'habits',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HabitsScreen(),
                ),
              ),
            ],
          ),

          // Tab 2: Focus
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.focus,
                name: 'focus',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FocusScreen(),
                ),
              ),
            ],
          ),

          // Tab 3: Analytics / Insights
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analytics,
                name: 'analytics',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AnalyticsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Standalone Screens ──────────────────────────────────────────

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),

      // Task Creation
      GoRoute(
        path: AppRoutes.taskCreate,
        name: 'taskCreate',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TaskEditorScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),

      // Task Editing
      GoRoute(
        path: AppRoutes.taskEditor,
        name: 'taskEditor',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final taskId = state.uri.queryParameters['id'];
          return CustomTransitionPage(
            key: state.pageKey,
            child: TaskEditorScreen(taskId: taskId),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),

      // Alarm Full Screen
      GoRoute(
        path: AppRoutes.alarmFullscreen,
        name: 'alarmFullscreen',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final taskId = state.uri.queryParameters['taskId'];
          return CustomTransitionPage(
            key: state.pageKey,
            child: AlarmFullscreen(taskId: taskId),
            transitionsBuilder: (context, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
          );
        },
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: _slideLeftTransition,
        ),
      ),

      // Login
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),

      // Photo Picker
      GoRoute(
        path: AppRoutes.photoPicker,
        name: 'photoPicker',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final taskId = state.uri.queryParameters['taskId'];
          return CustomTransitionPage(
            key: state.pageKey,
            child: PhotoPickerScreen(taskId: taskId),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),
    ],
  );
});

// ─── Transition Builders ───────────────────────────────────────────────────

Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    )),
    child: FadeTransition(opacity: animation, child: child),
  );
}

Widget _slideLeftTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    )),
    child: FadeTransition(opacity: animation, child: child),
  );
}
