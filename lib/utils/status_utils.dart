import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Daftar status laporan yang valid, urut sesuai alur proses.
/// Disamakan dengan enum status pada versi web Laravel (RoadFix):
/// Menunggu Verifikasi -> Diproses -> Selesai.
const List<String> kStatusOptions = [
  'Menunggu Verifikasi',
  'Diproses',
  'Selesai',
];

/// Daftar kategori kerusakan yang tersedia.
const List<String> kKategoriOptions = [
  'Berlubang',
  'Retak',
  'Jembatan',
  'Ambles',
  'Lainnya',
];

/// Daftar tingkat kerusakan yang tersedia.
const List<String> kTingkatKerusakanOptions = [
  'Ringan',
  'Sedang',
  'Berat',
];

/// Mengembalikan warna badge sesuai status laporan.
Color statusColorFor(String status) {
  switch (status) {
    case 'Menunggu Verifikasi':
      return AppColors.gold;
    case 'Diproses':
      return AppColors.orange;
    case 'Selesai':
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

/// Format tanggal panjang "dd MMMM yyyy" (mis. "13 July 2026") dipakai di
/// halaman Detail Laporan, konsisten dengan versi Laravel.
const List<String> _bulanPanjang = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String formatTanggalPanjang(DateTime date) {
  final dd = date.day.toString().padLeft(2, '0');
  final mmmm = _bulanPanjang[date.month - 1];
  return '$dd $mmmm ${date.year}';
}
