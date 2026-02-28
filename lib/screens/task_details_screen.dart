import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/app_controller.dart';
import '../providers/task_controller.dart';
import '../widgets/primary_button.dart';
import 'add_edit_task_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.goalName,
  });

  final TaskModel task;
  final String goalName;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final appController = context.read<AppController>();
    final taskController = context.read<TaskController>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appController.t('deleteTask')),
        content: Text(appController.t('deleteTaskConfirm')),
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
      final removed = await taskController.deleteTask(widget.task.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      if (removed != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appController.t('taskDeleted')),
            action: SnackBarAction(
              label: appController.t('undo'),
              onPressed: () => taskController.restoreTask(removed),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final taskController = context.watch<TaskController>();

    final currentTask = taskController.tasks.firstWhere(
      (item) => item.id == widget.task.id,
      orElse: () => widget.task,
    );

    final subtasks = currentTask.subtasks;
    final completedSubtasks = subtasks.where((s) => s.isDone).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(appController.t('taskDetails')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditTaskScreen(task: currentTask),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            currentTask.title,
            style: Theme.of(context).textTheme.headlineSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            widget.goalName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
              Flexible(
                child: Text(
                  currentTask.dueDate == null
                      ? appController.t('noDueDate')
                      : '${currentTask.dueDate!.day}/${currentTask.dueDate!.month}/${currentTask.dueDate!.year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.flag_outlined, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  currentTask.priority.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${appController.t('createdAt')}: ${currentTask.createdAt.day}/${currentTask.createdAt.month}/${currentTask.createdAt.year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  appController.t('subtasks'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (subtasks.isNotEmpty)
                Text('$completedSubtasks/${subtasks.length}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtaskController,
                  decoration: InputDecoration(
                    hintText: appController.t('subtaskHint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  final title = _subtaskController.text.trim();
                  if (title.isEmpty) return;
                  taskController.addSubtask(currentTask.id, title);
                  _subtaskController.clear();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (subtasks.isEmpty)
            Text(appController.t('noSubtasks'))
          else
            ...subtasks.map((subtask) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Checkbox(
                    value: subtask.isDone,
                    onChanged: (_) => taskController.toggleSubtask(
                      currentTask.id,
                      subtask.id,
                    ),
                  ),
                  title: Text(
                    subtask.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => taskController.deleteSubtask(
                      currentTask.id,
                      subtask.id,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
