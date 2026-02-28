import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_controller.dart';
import '../providers/goal_controller.dart';
import '../providers/task_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_list_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/stat_tile.dart';
import '../widgets/study_app_bar.dart';
import 'add_edit_goal_screen.dart';
import 'goal_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final goalController = context.watch<GoalController>();
    final taskController = context.watch<TaskController>();
    final userName =
        appController.user?.name ?? appController.t('defaultUserName');

    final totalTasks = taskController.tasks.length;
    final completedTasks = taskController.tasks
        .where((task) => task.isDone)
        .length;
    final goalCount = goalController.goals.length;
    final overdueTasks = taskController.tasks.where((task) {
      final due = task.dueDate;
      if (due == null || task.isDone) return false;
      return due.isBefore(DateTime.now());
    }).toList();

    final nextTask = taskController.tasks
        .where((task) => task.dueDate != null && !task.isDone)
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    final nextUp = nextTask.isEmpty ? null : nextTask.first;
    final activeGoal = goalController.activeGoal;

    return Scaffold(
      appBar: StudyAppBar(
        title: appController.t('home'),
      ),
      body: RefreshIndicator(
        onRefresh: goalController.loadGoals,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${appController.t('welcome')}, $userName',
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (overdueTasks.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appController.t('overdue'),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              appController.t('goals'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            if (nextUp != null && goalController.goals.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appController.t('nextUp'),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextUp.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (nextUp.dueDate != null)
                            Text(
                              '${nextUp.dueDate!.day}/${nextUp.dueDate!.month}/${nextUp.dueDate!.year}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GoalDetailsScreen(
                              goal: goalController.goals.firstWhere(
                                (g) => g.id == nextUp.goalId,
                                orElse: () => goalController.goals.first,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            if (activeGoal != null) ...[
              const SizedBox(height: 12),
              GoalCard(
                goal: activeGoal,
                daysLeftLabel: appController.t('daysLeft'),
                title: appController.t('nextGoal'),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: appController.t('goalsCount'),
                    value: goalCount.toString(),
                    icon: Icons.flag,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: appController.t('completed'),
                    value: '$completedTasks/$totalTasks',
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (goalController.goals.isEmpty)
              EmptyState(
                title: appController.t('goals'),
                message: appController.t('emptyGoals'),
                action: PrimaryButton(
                  label: appController.t('addGoal'),
                  icon: Icons.add,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddEditGoalScreen(),
                      ),
                    );
                  },
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: goalController.goals.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final goal = goalController.goals[index];
                    final goalTasks = taskController.tasksForGoal(goal.id);
                    final completed = goalTasks
                        .where((task) => task.isDone)
                        .length;
                    return SizedBox(
                      width: 190,
                      child: GoalListCard(
                        goal: goal,
                        progress:
                            goalTasks.isEmpty ? 0 : completed / goalTasks.length,
                        progressLabel:
                            '$completed/${goalTasks.length} ${appController.t('completed')}',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GoalDetailsScreen(goal: goal),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
