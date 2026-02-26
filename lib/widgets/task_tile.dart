import 'package:flutter/material.dart';

import '../models/task_model.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.subjectName,
    required this.onToggle,
    required this.onTap,
  });

  final TaskModel task;
  final String subjectName;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  Color _priorityColor(BuildContext context) {
    switch (task.priority) {
      case TaskPriority.high:
        return Colors.redAccent;
      case TaskPriority.medium:
        return Theme.of(context).colorScheme.primary;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _priorityLabel() {
    switch (task.priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: task.isDone, onChanged: (_) => onToggle()),
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subjectName),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _priorityColor(context).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _priorityLabel(),
                    style: TextStyle(
                      color: _priorityColor(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
