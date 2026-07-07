import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

class LaporanTerbaruItem extends StatelessWidget {
  final String judul;
  final String lokasi;
  final String status;
  final Color color;

  const LaporanTerbaruItem({
    super.key,
    required this.judul,
    required this.lokasi,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '$judul — $lokasi',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4),
          ),
        ),
        const SizedBox(width: 8),
        StatusBadge(label: status, color: color),
      ],
    );
  }
}
