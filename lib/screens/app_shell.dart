import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_controller.dart';
import '../widgets/bottom_nav_bar.dart';
import 'add_edit_goal_screen.dart';
import 'add_edit_task_screen.dart';
import 'home_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';

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
      floatingActionButton: _buildFab(context, appController.currentIndex),
      bottomNavigationBar: BottomNavBar(
        currentIndex: appController.currentIndex,
        onTap: appController.setTab,
        labels: [
          appController.t('home'),
          appController.t('tasks'),
          appController.t('progress'),
          appController.t('profile'),
        ],
        icons: const [
          Icons.home_rounded,
          Icons.check_circle_rounded,
          Icons.show_chart_rounded,
          Icons.person_rounded,
        ],
      ),
    );
  }

  Widget? _buildFab(BuildContext context, int index) {
    VoidCallback? onPressed;
    if (index == 0) {
      onPressed = () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditGoalScreen()),
        );
      };
    } else if (index == 1) {
      onPressed = () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
        );
      };
    }

    if (onPressed == null) return null;

    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.add_rounded),
    );
  }
}
