import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_controller.dart';
import '../providers/subject_controller.dart';
import '../providers/task_controller.dart';
import '../widgets/progress_card.dart';
import '../widgets/study_app_bar.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final subjectController = context.watch<SubjectController>();
    final taskController = context.watch<TaskController>();

    final totalTasks = taskController.tasks.length;
    final completedTasks =
        taskController.tasks.where((task) => task.isDone).length;
    final overallProgress =
        totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return Scaffold(
      appBar: StudyAppBar(title: appController.t('progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            appController.t('progressOverview'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ProgressCard(
            title: appController.t('overall'),
            progress: overallProgress,
            subtitle:
                '$completedTasks of $totalTasks ${appController.t('tasksCompleted')}',
          ),
          const SizedBox(height: 20),
          ...subjectController.subjects.map((subject) {
            final subjectTasks =
                taskController.tasksForSubject(subject.id);
            final completed = subjectTasks
                .where((task) => task.isDone)
                .length;
            final progress =
                subjectTasks.isEmpty ? 0.0 : completed / subjectTasks.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ProgressCard(
                title: subject.title,
                progress: progress,
                subtitle:
                    '$completed of ${subjectTasks.length} ${appController.t('completed')}',
              ),
            );
          }),
        ],
      ),
    );
  }
}
