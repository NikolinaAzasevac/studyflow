import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/models/notification_model.dart';

void main() {
  test('NotificationModel serializes and deserializes correctly', () {
    final createdAt = DateTime(2026, 5, 26, 14, 30);
    final model = NotificationModel(
      id: 'notification-1',
      userId: 'user-1',
      title: 'Task completed!',
      message: 'You completed your task.',
      type: 'task_reminder',
      isRead: false,
      createdAt: createdAt,
      data: {'taskId': 'task-1'},
    );

    final map = model.toMap();

    final restored = NotificationModel.fromMap('notification-1', map);

    expect(restored.id, 'notification-1');
    expect(restored.userId, 'user-1');
    expect(restored.title, 'Task completed!');
    expect(restored.message, 'You completed your task.');
    expect(restored.type, 'task_reminder');
    expect(restored.isRead, isFalse);
    expect(restored.createdAt, createdAt);
    expect(restored.data?['taskId'], 'task-1');
  });
}
