import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_controller.dart';
import '../providers/subject_controller.dart';
import '../providers/task_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/primary_button.dart';
import '../widgets/stat_tile.dart';
import '../widgets/study_app_bar.dart';
import '../widgets/subject_card.dart';
import 'add_edit_subject_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final subjectController = context.watch<SubjectController>();
    final taskController = context.watch<TaskController>();
    final userName =
        appController.user?.name ?? appController.t('defaultUserName');

    final totalTasks = taskController.tasks.length;
    final completedTasks = taskController.tasks
        .where((task) => task.isDone)
        .length;
    final subjectCount = subjectController.subjects.length;

    return Scaffold(
      appBar: StudyAppBar(
        title: appController.t('home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddEditSubjectScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: subjectController.loadSubjects,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '${appController.t('welcome')}, $userName',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              appController.t('subjects'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: appController.t('subjectsCount'),
                    value: subjectCount.toString(),
                    icon: Icons.auto_awesome_mosaic,
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
            if (subjectController.subjects.isEmpty)
              EmptyState(
                title: appController.t('subjects'),
                message: appController.t('emptySubjects'),
                action: PrimaryButton(
                  label: appController.t('addSubject'),
                  icon: Icons.add,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddEditSubjectScreen(),
                      ),
                    );
                  },
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: subjectController.subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjectController.subjects[index];
                  final subjectTasks = taskController.tasksForSubject(
                    subject.id,
                  );
                  final completed = subjectTasks
                      .where((task) => task.isDone)
                      .length;
                  return SubjectCard(
                    subject: subject,
                    progressLabel: appController.t('completed'),
                    completedTasks: completed,
                    totalTasks: subjectTasks.length,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AddEditSubjectScreen(subject: subject),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
