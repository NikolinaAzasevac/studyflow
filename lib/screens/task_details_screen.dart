import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/app_controller.dart';
import '../providers/task_controller.dart';
import '../widgets/primary_button.dart';
import 'add_edit_task_screen.dart';

class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.subjectName,
  });

  final TaskModel task;
  final String subjectName;

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final taskController = context.watch<TaskController>();
    final currentTask = taskController.tasks.firstWhere(
      (item) => item.id == task.id,
      orElse: () => task,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(appController.t('taskDetails')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditTaskScreen(task: task),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            currentTask.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(subjectName),
          const SizedBox(height: 16),
          if (currentTask.notes.isNotEmpty)
            Text(
              currentTask.notes,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 8),
              Text(
                currentTask.dueDate == null
                    ? appController.t('noDueDate')
                    : '${currentTask.dueDate!.day}/${currentTask.dueDate!.month}/${currentTask.dueDate!.year}',
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: currentTask.isDone
                ? appController.t('markPending')
                : appController.t('markDone'),
            icon: Icons.check,
            onPressed: () => taskController.toggleTask(currentTask),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              taskController.deleteTask(currentTask.id);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete_outline),
            label: Text(appController.t('deleteTask')),
          ),
        ],
      ),
    );
  }
}
