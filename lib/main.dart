import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_controller.dart';
import 'providers/goal_controller.dart';
import 'providers/task_controller.dart';
import 'repositories/mock_task_repository.dart';
import 'repositories/mock_goal_repository.dart';
import 'repositories/goal_repository.dart';
import 'repositories/task_repository.dart';
import 'services/unsplash_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final goalRepository = MockGoalRepository();
  final goals = await goalRepository.fetchAll();
  final taskRepository = MockTaskRepository();
  taskRepository.seedForGoals(goals);

  runApp(
    StudyFlowApp(
      taskRepository: taskRepository,
      goalRepository: goalRepository,
    ),
  );
}

class StudyFlowApp extends StatefulWidget {
  const StudyFlowApp({
    super.key,
    required this.taskRepository,
    required this.goalRepository,
  });

  final TaskRepository taskRepository;
  final GoalRepository goalRepository;

  @override
  State<StudyFlowApp> createState() => _StudyFlowAppState();
}

class _StudyFlowAppState extends State<StudyFlowApp> {
  late final AppController _appController;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _appController = AppController();
    _appController.loadPreferences().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
      secondary: Colors.deepPurpleAccent,
      tertiary: Colors.green,
    );

    final darkScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
      tertiary: Colors.greenAccent,
    );

    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorScheme: colorScheme),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _appController),
        ChangeNotifierProvider(
          create: (_) => TaskController(
            widget.taskRepository,
            onTaskCompleted: _appController.recordActivity,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalController(widget.goalRepository, UnsplashService()),
        ),
      ],
      child: Consumer<AppController>(
        builder: (context, appController, _) {
          return MaterialApp(
            title: appController.t('appTitle'),
            debugShowCheckedModeBanner: false,
            locale: Locale(appController.localeCode),
            themeMode: appController.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: colorScheme,
              scaffoldBackgroundColor: const Color(0xFFF6F4FA),
              cardTheme: CardThemeData(
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkScheme,
              scaffoldBackgroundColor: const Color(0xFF101014),
              inputDecorationTheme: const InputDecorationTheme(
                filled: true,
                fillColor: Color(0xFF1C1C22),
              ),
            ),
            home: appController.hasSeenOnboarding
                ? (appController.isAuthenticated
                    ? const AppShell()
                    : const LoginScreen())
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
