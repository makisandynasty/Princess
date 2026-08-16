import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/alarm/data/services/alarm_scheduler_service.dart';
import '../features/alarm/presentation/widgets/alarm_ringing_overlay.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// Root application widget.
class PrincessApp extends ConsumerWidget {
  const PrincessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Attach active router to the alarm scheduler so it can push alarm screen
    final scheduler = ref.read(alarmSchedulerServiceProvider.notifier);
    scheduler.attachRouter(router);

    return MaterialApp.router(
      title: 'Princess',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (context, child) {
        return AlarmRingingOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
