import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'card_container.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String note;
  final Color noteColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.note,
    required this.noteColor,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: TextStyle(color: noteColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
