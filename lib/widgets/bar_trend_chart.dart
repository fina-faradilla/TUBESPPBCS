import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BarTrendChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const BarTrendChart({super.key, required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    final rawMax = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a > b ? a : b);
    final maxVal = rawMax <= 0 ? 1.0 : rawMax;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(values.length, (i) {
            final heightRatio = values[i] / maxVal;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 32,
                  height: (constraints.maxHeight - 30) * heightRatio,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[i],
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
