import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_controller.dart';
import 'providers/subject_controller.dart';
import 'providers/task_controller.dart';
import 'repositories/mock_subject_repository.dart';
import 'repositories/mock_task_repository.dart';
import 'repositories/subject_repository.dart';
import 'repositories/task_repository.dart';
import 'services/unsplash_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/tasks_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final subjectRepository = MockSubjectRepository();
  final subjects = await subjectRepository.fetchAll();
  final taskRepository = MockTaskRepository();
  taskRepository.seedForSubjects(subjects);

  runApp(
    StudyFlowApp(
      subjectRepository: subjectRepository,
      taskRepository: taskRepository,
    ),
  );
}

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({
    super.key,
    required this.subjectRepository,
    required this.taskRepository,
  });

  final SubjectRepository subjectRepository;
  final TaskRepository taskRepository;

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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppController()),
        ChangeNotifierProvider(
          create: (_) =>
              SubjectController(subjectRepository, UnsplashService()),
        ),
        ChangeNotifierProvider(create: (_) => TaskController(taskRepository)),
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
              inputDecorationTheme: InputDecorationTheme(
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
            home: appController.isAuthenticated
                ? const AppShell()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const _screens = [
    HomeScreen(),
    TasksScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();

    return Scaffold(
      body: IndexedStack(index: appController.currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: appController.currentIndex,
        onTap: appController.setTab,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: appController.t('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle_outline),
            activeIcon: const Icon(Icons.check_circle),
            label: appController.t('tasks'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart),
            activeIcon: const Icon(Icons.show_chart),
            label: appController.t('progress'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: appController.t('profile'),
          ),
        ],
      ),
    );
  }
}
