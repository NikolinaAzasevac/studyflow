import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.title,
    required this.progress,
    required this.subtitle,
    this.emphasize = false,
    this.trailing,
  });

  final String title;
  final double progress;
  final String subtitle;
  final bool emphasize;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final titleStyle = emphasize
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.titleMedium;
    final subtitleStyle = emphasize
        ? Theme.of(context).textTheme.bodyMedium
        : Theme.of(context).textTheme.labelMedium;

    return Container(
      padding: EdgeInsets.all(emphasize ? 20 : 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: emphasize ? 16 : 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: emphasize ? 12 : 10,
              color: scheme.tertiary,
              backgroundColor: scheme.tertiary.withValues(alpha: 0.2),
            ),
          ),
          SizedBox(height: emphasize ? 10 : 8),
          Text(
            subtitle,
            style: subtitleStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
