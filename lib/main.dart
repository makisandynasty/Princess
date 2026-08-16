import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/supabase_service.dart';
import 'features/habits/data/datasources/habit_local_datasource.dart';
import 'features/habits/presentation/controllers/habit_controller.dart';
import 'features/tasks/data/datasources/task_local_datasource.dart';
import 'features/tasks/presentation/controllers/task_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Supabase Backend
  await SupabaseService.instance.init();

  // Initialize Task Local Datasource
  final taskDatasource = TaskLocalDatasource();
  await taskDatasource.init();

  // Initialize Habit Local Datasource
  final habitDatasource = HabitLocalDatasource();
  await habitDatasource.init();

  runApp(
    ProviderScope(
      overrides: [
        taskDatasourceProvider.overrideWithValue(taskDatasource),
        habitDatasourceProvider.overrideWithValue(habitDatasource),
      ],
      child: const PrincessApp(),
    ),
  );
}
