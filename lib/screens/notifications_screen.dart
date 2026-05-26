import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notification_model.dart';
import '../providers/app_controller.dart';
import '../providers/goal_controller.dart';
import '../providers/notification_controller.dart';
import '../providers/task_controller.dart';
import '../widgets/study_app_bar.dart';
import 'goal_details_screen.dart';
import 'task_details_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  void _showMissingTargetMessage(BuildContext context, AppController appController) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(appController.t('notificationTargetMissing')),
        showCloseIcon: true,
      ),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    NotificationModel notification,
  ) async {
    final appController = context.read<AppController>();
    final notificationController = context.read<NotificationController>();
    final goalController = context.read<GoalController>();
    final taskController = context.read<TaskController>();

    if (!notification.isRead) {
      await notificationController.markAsRead(notification.id);
    }

    switch (notification.type) {
      case 'task_reminder':
        final taskId = notification.data?['taskId'] as String?;
        if (taskId == null) {
          _showMissingTargetMessage(context, appController);
          return;
        }
        final matches = taskController.tasks.where((task) => task.id == taskId);
        if (matches.isEmpty) {
          _showMissingTargetMessage(context, appController);
          return;
        }
        final task = matches.first;
        final goalMatches = goalController.goals.where((goal) => goal.id == task.goalId);
        final goalName = goalMatches.isEmpty
            ? appController.t('unknownGoal')
            : goalMatches.first.displayTitle;
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TaskDetailsScreen(task: task, goalName: goalName),
          ),
        );
        return;
      case 'goal_deadline':
        final goalId = notification.data?['goalId'] as String?;
        if (goalId == null) {
          _showMissingTargetMessage(context, appController);
          return;
        }
        final matches = goalController.goals.where((goal) => goal.id == goalId);
        if (matches.isEmpty) {
          _showMissingTargetMessage(context, appController);
          return;
        }
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GoalDetailsScreen(goal: matches.first),
          ),
        );
        return;
      case 'streak':
        appController.setTab(2);
        return;
      case 'system':
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final notificationController = context.watch<NotificationController>();

    return Scaffold(
      appBar: StudyAppBar(
        title: appController.t('notifications'),
        actions: [
          if (notificationController.unreadCount > 0)
            TextButton(
              onPressed: () => notificationController.markAllAsRead(),
              child: Text(appController.t('markAllRead')),
            ),
        ],
      ),
      body: notificationController.notifications.isEmpty
          ? Center(child: Text(appController.t('noNotifications')))
          : ListView.builder(
              itemCount: notificationController.notifications.length,
              itemBuilder: (context, index) {
                final notification =
                    notificationController.notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => notificationController.deleteNotification(
                    notification.id,
                  ),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _getIconForType(notification.type),
                      color: notification.isRead
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.message),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(context, notification.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: notification.isRead
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                    onTap: () => _handleTap(context, notification),
                  ),
                );
              },
            ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'task_reminder':
        return Icons.task;
      case 'goal_deadline':
        return Icons.flag;
      case 'streak':
        return Icons.local_fire_department;
      case 'system':
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final appController = context.read<AppController>();

    if (difference.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return appController.t('yesterday');
    } else if (difference.inDays < 7) {
      return appController.formatMessage('daysAgo', {
        'count': '${difference.inDays}',
      });
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
