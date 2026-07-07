import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Daftar status laporan yang valid, urut sesuai alur proses.
const List<String> kStatusOptions = [
  'BARU',
  'DIVERIFIKASI',
  'DIPROSES',
  'SELESAI',
];

/// Daftar kategori kerusakan yang tersedia.
const List<String> kKategoriOptions = [
  'Berlubang',
  'Retak',
  'Jembatan',
  'Ambles',
  'Lainnya',
];

/// Mengembalikan warna badge sesuai status laporan.
Color statusColorFor(String status) {
  switch (status) {
    case 'BARU':
      return AppColors.blue;
    case 'DIPROSES':
      return AppColors.orange;
    case 'DIVERIFIKASI':
      return AppColors.amberBadge;
    case 'SELESAI':
      return AppColors.green;
    default:
      return AppColors.textSecondary;
  }
}

const List<String> _bulanPendek = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Format tanggal menjadi "dd MMM yyyy" (mis. "07 Jul 2026") tanpa
/// bergantung pada package intl, konsisten dengan data contoh yang ada.
String formatTanggal(DateTime date) {
  final dd = date.day.toString().padLeft(2, '0');
  final mmm = _bulanPendek[date.month - 1];
  return '$dd $mmm ${date.year}';
}
