import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/app_controller.dart';
import '../../providers/goal_controller.dart';
import '../../providers/task_controller.dart';
import '../../repositories/firebase_goal_repository.dart';
import '../../repositories/firebase_task_repository.dart';
import '../../services/unsplash_service.dart';
import '../add_edit_goal_screen.dart';
import '../add_edit_task_screen.dart';
import '../goal_details_screen.dart';
import '../task_details_screen.dart';

class AdminUserDataScreen extends StatefulWidget {
  const AdminUserDataScreen({
    super.key,
    required this.user,
    required this.goalController,
    required this.taskController,
    this.ownsControllers = false,
  });

  factory AdminUserDataScreen.forUser({Key? key, required UserModel user}) {
    final goalController = GoalController(
      FirebaseGoalRepository(FirebaseFirestore.instance),
      UnsplashService(),
    )..setUserId(user.id);
    final taskController = TaskController(
      FirebaseTaskRepository(FirebaseFirestore.instance),
    )..setUserId(user.id);

    return AdminUserDataScreen(
      key: key,
      user: user,
      goalController: goalController,
      taskController: taskController,
      ownsControllers: true,
    );
  }

  final UserModel user;
  final GoalController goalController;
  final TaskController taskController;
  final bool ownsControllers;

  @override
  State<AdminUserDataScreen> createState() => _AdminUserDataScreenState();
}

class _AdminUserDataScreenState extends State<AdminUserDataScreen> {
  @override
  void dispose() {
    if (widget.ownsControllers) {
      widget.goalController.dispose();
      widget.taskController.dispose();
    }
    super.dispose();
  }

  String _goalName(
    AppController appController,
    GoalController controller,
    String goalId,
  ) {
    final match = controller.goals.where((g) => g.id == goalId).toList();
    if (match.isEmpty) return appController.t('unknownGoal');
    return match.first.displayTitle;
  }

  Future<void> _pushWithUserProviders(
    BuildContext context,
    Widget child,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<GoalController>.value(
              value: widget.goalController,
            ),
            ChangeNotifierProvider<TaskController>.value(
              value: widget.taskController,
            ),
          ],
          child: child,
        ),
      ),
    );
    await widget.goalController.loadGoals();
    await widget.taskController.loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    if (!appController.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(appController.t('manageData'))),
        body: Center(child: Text(appController.t('notAuthorized'))),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GoalController>.value(
          value: widget.goalController,
        ),
        ChangeNotifierProvider<TaskController>.value(
          value: widget.taskController,
        ),
      ],
      child: Builder(
        builder: (context) {
          final goalController = context.watch<GoalController>();
          final taskController = context.watch<TaskController>();

          return Scaffold(
            appBar: AppBar(title: Text(appController.t('manageData'))),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name.isEmpty
                              ? appController.t('notSet')
                              : widget.user.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.user.email.isEmpty
                              ? appController.t('notSet')
                              : widget.user.email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _pushWithUserProviders(
                            context,
                            const AddEditGoalScreen(),
                          );
                        },
                        icon: const Icon(Icons.flag_outlined),
                        label: Text(appController.t('addGoal')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _pushWithUserProviders(
                            context,
                            const AddEditTaskScreen(),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(appController.t('addTask')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  appController.t('goals'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (goalController.goals.isEmpty)
                  Text(appController.t('emptyGoals'))
                else
                  ...goalController.goals.map((goal) {
                    final goalTasks = taskController.tasksForGoal(goal.id);
                    final completed = goalTasks
                        .where((task) => task.isDone)
                        .length;
                    final total = goalTasks.length;
                    final progress = total == 0 ? 0.0 : completed / total;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tileColor: Theme.of(context).colorScheme.surface,
                        title: Text(goal.displayTitle),
                        subtitle: Text(
                          '$completed/$total ${appController.t('completed')}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () {
                            _pushWithUserProviders(
                              context,
                              GoalDetailsScreen(goal: goal),
                            );
                          },
                        ),
                        leading: SizedBox(
                          width: 40,
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            color: Theme.of(context).colorScheme.tertiary,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.tertiary.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 12),
                Text(
                  appController.t('tasks'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (taskController.tasks.isEmpty)
                  Text(appController.t('emptyTasks'))
                else
                  ...taskController.tasks.map((task) {
                    final goalName = _goalName(
                      appController,
                      goalController,
                      task.goalId,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tileColor: Theme.of(context).colorScheme.surface,
                        title: Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          goalName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () {
                            _pushWithUserProviders(
                              context,
                              TaskDetailsScreen(task: task, goalName: goalName),
                            );
                          },
                        ),
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (_) => taskController.toggleTask(task),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
