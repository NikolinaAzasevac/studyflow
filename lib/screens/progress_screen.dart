import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_controller.dart';
import '../providers/goal_controller.dart';
import '../providers/task_controller.dart';
import '../widgets/progress_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/stat_tile.dart';
import '../widgets/study_app_bar.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/goal_progress_chip.dart';
import '../widgets/demo_notice_card.dart';
import 'auth/login_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  Future<void> _resetProgress(BuildContext context) async {
    final appController = context.read<AppController>();
    final taskController = context.read<TaskController>();
    final goalController = context.read<GoalController>();
    final scheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appController.t('resetProgress')),
        content: Text(appController.t('resetProgressConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(appController.t('no')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(appController.t('yes')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await taskController.clearAll();
      await goalController.clearAll();
      appController.clearActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final goalController = context.watch<GoalController>();
    final taskController = context.watch<TaskController>();

    final totalTasks = taskController.tasks.length;
    final completedTasks = taskController.tasks
        .where((task) => task.isDone)
        .length;
    final overallProgress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    final streak = appController.streakDays();
    final trend = appController.weeklyTrend();
    final thisWeek = trend['thisWeek'] ?? 0;
    final lastWeek = trend['lastWeek'] ?? 0;
    final trendLabel = thisWeek >= lastWeek
        ? appController.t('trendUp')
        : appController.t('trendDown');
    final weeklySeries = appController.weeklySeries();
    final activeGoal = goalController.activeGoal;
    String? goalCountdown;
    if (activeGoal != null) {
      final now = DateTime.now();
      goalCountdown =
          '${activeGoal.targetDate.difference(DateTime(now.year, now.month, now.day)).inDays} ${appController.t('daysLeft')}';
    }

    return Scaffold(
      appBar: StudyAppBar(title: appController.t('progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (appController.isGuest) ...[
            DemoNoticeCard(
              title: appController.t('demoModeTitle'),
              message: appController.t('demoModeMessage'),
              actionLabel: appController.t('demoModeAction'),
              onAction: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
          Text(
            appController.t('progressOverview'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ProgressRing(
                progress: overallProgress,
                label: '${(overallProgress * 100).round()}%',
                subtitle: '$completedTasks/$totalTasks',
                footer: goalCountdown,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appController.t('overall'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${appController.t('thisWeek')}: $thisWeek',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appController.t('lastWeek')}: $lastWeek',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trendLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          WeeklyChart(values: weeklySeries),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: appController.t('streak'),
                  value: '$streak',
                  icon: Icons.local_fire_department,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: appController.t('thisWeek'),
                  value: '$thisWeek',
                  icon: Icons.calendar_today,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProgressCard(
            title: appController.t('overall'),
            progress: overallProgress,
            subtitle:
                '$completedTasks of $totalTasks ${appController.t('tasksCompleted')}',
            emphasize: true,
          ),
          const SizedBox(height: 20),
          ...goalController.goals.map((goal) {
            final goalTasks = taskController.tasksForGoal(goal.id);
            final completed = goalTasks.where((task) => task.isDone).length;
            final progress = goalTasks.isEmpty
                ? 0.0
                : completed / goalTasks.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ProgressCard(
                title: goal.displayTitle,
                progress: progress,
                subtitle:
                    '$completed of ${goalTasks.length} ${appController.t('completed')}',
                trailing: GoalProgressChip(
                  label: '${(progress * 100).round()}%',
                ),
              ),
            );
          }),
          if (appController.isAuthenticated) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.restart_alt,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(appController.t('resetProgress')),
                subtitle: Text(appController.t('resetProgressConfirmShort')),
                trailing: TextButton(
                  onPressed: () => _resetProgress(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(appController.t('reset')),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
