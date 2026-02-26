import 'package:flutter/material.dart';

import '../models/subject_model.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
    required this.progressLabel,
    required this.completedTasks,
    required this.totalTasks,
  });

  final SubjectModel subject;
  final VoidCallback onTap;
  final String progressLabel;
  final int completedTasks;
  final int totalTasks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: scheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: subject.coverUrl == null
                    ? Container(
                        color: scheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 42,
                          color: scheme.primary,
                        ),
                      )
                    : Image.network(subject.coverUrl!, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subject.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      color: scheme.tertiary,
                      backgroundColor: scheme.tertiary.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$completedTasks/$totalTasks $progressLabel',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
