import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_controller.dart';
import '../providers/notification_controller.dart';
import '../widgets/study_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
                          _formatDate(notification.createdAt),
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
                    onTap: () {
                      if (!notification.isRead) {
                        notificationController.markAsRead(notification.id);
                      }
                      // TODO: Handle navigation based on notification type/data
                    },
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
