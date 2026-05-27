import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/task_model.dart';
import 'providers/admin_controller.dart';
import 'providers/app_controller.dart';
import 'providers/goal_controller.dart';
import 'providers/notification_controller.dart';
import 'providers/task_controller.dart';
import 'repositories/firebase_goal_repository.dart';
import 'repositories/firebase_public_goal_repository.dart';
import 'repositories/firebase_public_task_repository.dart';
import 'repositories/firebase_task_repository.dart';
import 'repositories/firebase_user_repository.dart';
import 'repositories/goal_repository.dart';
import 'repositories/hybrid_goal_repository.dart';
import 'repositories/hybrid_task_repository.dart';
import 'repositories/notification_repository.dart';
import 'repositories/task_repository.dart';
import 'repositories/user_repository.dart';
import 'services/unsplash_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    StudyFlowApp(
      firebaseTaskRepository: HybridTaskRepository(
        FirebaseTaskRepository(FirebaseFirestore.instance),
        FirebasePublicTaskRepository(FirebaseFirestore.instance),
      ),
      firebaseGoalRepository: HybridGoalRepository(
        FirebaseGoalRepository(FirebaseFirestore.instance),
        FirebasePublicGoalRepository(FirebaseFirestore.instance),
      ),
      notificationRepository: NotificationRepository(
        FirebaseFirestore.instance,
      ),
      userRepository: FirebaseUserRepository(FirebaseFirestore.instance),
    ),
  );
}

class StudyFlowApp extends StatefulWidget {
  const StudyFlowApp({
    super.key,
    required this.firebaseTaskRepository,
    required this.firebaseGoalRepository,
    required this.notificationRepository,
    required this.userRepository,
  });

  final TaskRepository firebaseTaskRepository;
  final GoalRepository firebaseGoalRepository;
  final NotificationRepository notificationRepository;
  final UserRepository userRepository;

  @override
  State<StudyFlowApp> createState() => _StudyFlowAppState();
}

class _StudyFlowAppState extends State<StudyFlowApp> {
  late final AppController _appController;
  late final NotificationController _notificationController;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _appController = AppController();
    _notificationController = NotificationController(
      widget.notificationRepository,
    );
    _appController.notificationController = _notificationController;
    _appController.initialize().then((_) {
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
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _appController),
        ChangeNotifierProxyProvider<AppController, TaskController>(
          create: (_) => TaskController(
            widget.firebaseTaskRepository,
            onTaskCompleted: (TaskModel? task, DateTime date) =>
                _appController.recordActivity(date, task: task),
          ),
          update: (_, appController, controller) {
            controller?.setUserId(
              appController.isLoggedIn ? appController.user?.id : null,
            );
            return controller!;
          },
        ),
        ChangeNotifierProxyProvider<AppController, GoalController>(
          create: (_) => GoalController(
            widget.firebaseGoalRepository,
            UnsplashService(),
            onGoalAdded: _appController.addGoalNotification,
          ),
          update: (_, appController, controller) {
            controller?.setUserId(
              appController.isLoggedIn ? appController.user?.id : null,
            );
            return controller!;
          },
        ),
        ChangeNotifierProxyProvider<AppController, NotificationController>(
          create: (_) => _notificationController,
          update: (_, appController, controller) {
            controller?.setUserId(
              appController.isLoggedIn ? appController.user?.id : null,
            );
            return controller!;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => AdminController(widget.userRepository),
        ),
      ],
      child: Consumer<AppController>(
        builder: (context, appController, _) {
          Widget home;
          if (!appController.hasSeenOnboarding) {
            home = const OnboardingScreen();
          } else if (appController.isAuthResolving) {
            home = const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (appController.isSessionReady) {
            home = const AppShell();
          } else {
            home = const LoginScreen();
          }

          return MaterialApp(
            title: 'StudyFlow',
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
            home: home,
          );
        },
      ),
    );
  }
}
