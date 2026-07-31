import 'package:flutter/material.dart';

/// Warna-warna tema RoadFix (dark theme).
class AppColors {
  AppColors._();

  static const bgDark = Color(0xFF0F1117);
  static const sidebarBg = Color(0xFF15171F);
  static const cardBg = Color(0xFF1B1E27);
  static const cardBorder = Color(0xFF262933);
  static const gold = Color(0xFFF2A93B);
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0xFF9CA0AB);
  static const green = Color(0xFF3FBF7F);
  static const blue = Color(0xFF4E8CF5);
  static const orange = Color(0xFFF2994A);
  static const amberBadge = Color(0xFFCF9A3B);

  // TODO: belum ada warna merah di palet asli — dipakai untuk status
  // DITOLAK dan tingkat kerusakan BERAT. Ganti hex-nya kalau sudah
  // ada warna resmi dari desain.
  static const red = Color(0xFFE0575F);

  /// Warna teks di atas tombol/badge ber-background [gold].
  static const onGold = bgDark;

  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'BARU':
        return blue;
      case 'DIPROSES':
        return amberBadge;
      case 'SELESAI':
        return green;
      case 'DITOLAK':
        return red;
      default:
        return textSecondary;
    }
  }

  static Color tingkatColor(String tingkat) {
    switch (tingkat.toLowerCase()) {
      case 'berat':
        return red;
      case 'sedang':
        return orange;
      default:
        return green;
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      fontFamily: 'Poppins',
      primaryColor: AppColors.gold,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.gold,
        surface: AppColors.cardBg,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodySmall: TextStyle(color: AppColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgDark,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.onGold,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
