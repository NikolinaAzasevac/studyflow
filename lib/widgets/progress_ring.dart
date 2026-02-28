import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.label,
    required this.subtitle,
    this.footer,
  });

  final double progress;
  final String label;
  final String subtitle;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 140,
              width: 140,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 10,
                color: scheme.primary,
                backgroundColor: scheme.primary.withOpacity(0.15),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                if (footer != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    footer!,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}
