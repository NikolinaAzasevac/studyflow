import 'package:flutter/material.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key, required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final maxVal = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values
            .map(
              (value) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: value.toDouble()),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, animValue, _) {
                      final height =
                          maxVal == 0 ? 4 : (animValue / maxVal) * 60;
                      return Container(
                        height: height + 6,
                        decoration: BoxDecoration(
                          color: scheme.primary.withOpacity(
                            0.2 +
                                0.6 * (value / (maxVal == 0 ? 1 : maxVal)),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
