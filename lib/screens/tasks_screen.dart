import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_controller.dart';
import '../providers/subject_controller.dart';
import '../providers/task_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/primary_button.dart';
import '../widgets/study_app_bar.dart';
import '../widgets/task_tile.dart';
import 'add_edit_task_screen.dart';
import 'task_details_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  String _subjectName(
    AppController appController,
    SubjectController controller,
    String subjectId,
  ) {
    final match = controller.subjects
        .where((item) => item.id == subjectId)
        .toList();
    if (match.isEmpty) return appController.t('unknownSubject');
    return match.first.title;
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final taskController = context.watch<TaskController>();
    final subjectController = context.watch<SubjectController>();

    return Scaffold(
      appBar: StudyAppBar(
        title: appController.t('tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddEditTaskScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: taskController.tasks.isEmpty
          ? EmptyState(
              title: appController.t('tasks'),
              message: appController.t('emptyTasks'),
              action: PrimaryButton(
                label: appController.t('addTask'),
                icon: Icons.add,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddEditTaskScreen(),
                    ),
                  );
                },
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: taskController.tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = taskController.tasks[index];
                final subjectName = _subjectName(
                  appController,
                  subjectController,
                  task.subjectId,
                );
                return TaskTile(
                  task: task,
                  subjectName: subjectName,
                  onToggle: () => taskController.toggleTask(task),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TaskDetailsScreen(
                          task: task,
                          subjectName: subjectName,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: taskController.tasks.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddEditTaskScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
