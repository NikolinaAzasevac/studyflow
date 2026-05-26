import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal_model.dart';
import '../providers/app_controller.dart';
import '../providers/goal_controller.dart';
import '../providers/task_controller.dart';
import '../widgets/primary_button.dart';
import '../widgets/study_app_bar.dart';
import '../widgets/task_tile.dart';
import 'add_edit_goal_screen.dart';
import 'add_edit_task_screen.dart';
import 'task_details_screen.dart';

class GoalDetailsScreen extends StatelessWidget {
  const GoalDetailsScreen({super.key, required this.goal});

  final GoalModel goal;

  Future<void> _confirmDelete(BuildContext context) async {
    final appController = context.read<AppController>();
    final goalController = context.read<GoalController>();
    final taskController = context.read<TaskController>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appController.t('deleteGoal')),
        content: Text(appController.t('deleteGoalConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(appController.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(appController.t('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final removedTasks = await taskController.deleteTasksForGoal(goal.id);
      await goalController.deleteGoal(goal.id);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appController.t('goalDeleted')),
          showCloseIcon: true,
          action: SnackBarAction(
            label: appController.t('undo'),
            onPressed: () {
              goalController.restoreGoal(goal);
              taskController.restoreTasks(removedTasks);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final goalController = context.watch<GoalController>();
    final taskController = context.watch<TaskController>();

    final currentGoal = goalController.goals.firstWhere(
      (item) => item.id == goal.id,
      orElse: () => goal,
    );
    final goalTasks = taskController.tasksForGoal(currentGoal.id);
    final completed = goalTasks.where((task) => task.isDone).length;
    final total = goalTasks.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      appBar: StudyAppBar(
        title: appController.t('goalDetails'),
        actions: appController.isAuthenticated
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditGoalScreen(goal: currentGoal),
                      ),
                    );
                    if (!context.mounted) return;
                    await goalController.loadGoals();
                    await taskController.loadTasks();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context),
                ),
              ]
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 180,
              child: currentGoal.coverUrl == null
                  ? Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.flag,
                        size: 56,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Image.network(
                      currentGoal.coverUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            currentGoal.displayTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            currentGoal.description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 8),
              Text(
                '${currentGoal.targetDate.day}/${currentGoal.targetDate.month}/${currentGoal.targetDate.year}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              color: Theme.of(context).colorScheme.tertiary,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completed/$total ${appController.t('completed')}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  appController.t('tasks'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: appController.isAuthenticated
                    ? () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditTaskScreen(goalId: currentGoal.id),
                          ),
                        );
                        if (!context.mounted) return;
                        await taskController.loadTasks();
                        await goalController.loadGoals();
                      }
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (goalTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(appController.t('emptyTasks')),
            )
          else
            ...goalTasks.map((task) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskTile(
                  task: task,
                  goalName: currentGoal.displayTitle,
                  onToggle: appController.isAuthenticated
                      ? () => taskController.toggleTask(task)
                      : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TaskDetailsScreen(
                          task: task,
                          goalName: currentGoal.displayTitle,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          const SizedBox(height: 16),
          if (appController.isAuthenticated)
            PrimaryButton(
              label: appController.t('addTask'),
              icon: Icons.add,
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEditTaskScreen(goalId: currentGoal.id),
                  ),
                );
                if (!context.mounted) return;
                await taskController.loadTasks();
                await goalController.loadGoals();
              },
            ),
        ],
      ),
    );
  }
}
