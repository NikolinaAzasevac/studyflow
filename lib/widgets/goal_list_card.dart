import 'package:flutter/material.dart';

import '../models/goal_model.dart';

class GoalListCard extends StatelessWidget {
  const GoalListCard({
    super.key,
    required this.goal,
    required this.progress,
    required this.progressLabel,
    required this.onTap,
  });

  final GoalModel goal;
  final double progress;
  final String progressLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: scheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: SizedBox(
                height: 80,
                width: double.infinity,
                child: goal.coverUrl == null
                    ? Container(
                        color: scheme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.flag,
                          size: 40,
                          color: scheme.primary,
                        ),
                      )
                    : Image.network(goal.coverUrl!, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (goal.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      goal.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      color: scheme.tertiary,
                      backgroundColor: scheme.tertiary.withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progressLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
