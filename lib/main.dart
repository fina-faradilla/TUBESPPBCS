import 'package:flutter/material.dart';

import 'theme/app_colors.dart';
import 'screens/public/landing_page.dart';
import 'screens/public/login_page.dart';
import 'screens/public/register_page.dart';
import 'screens/admin/dashboard_page.dart';
import 'screens/admin/manage_report_page.dart';
import 'screens/admin/manage_category_page.dart';
import 'screens/admin/detail_laporan_page.dart';

void main() {
  runApp(const RoadFixApp());
}

class RoadFixApp extends StatelessWidget {
  const RoadFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoadFix',

      theme: ThemeData(
        colorSchemeSeed: Colors.orange,
        useMaterial3: true,
        // Sebelumnya brightness tidak diset -> Flutter otomatis pakai tema
        // TERANG bawaan Material 3, jadi Scaffold yang tidak memberi
        // `backgroundColor` sendiri (dashboard/manage-report/detail-laporan)
        // ikut jadi putih. Dua baris ini memastikan default-nya gelap.
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/admin/dashboard': (context) => const DashboardPage(),
        '/admin/manage-report': (context) => const ManageReportPage(),
        '/admin/manage-category': (context) => const ManageCategoryPage(),
        '/admin/detail-laporan': (context) => const DetailLaporanPage(),
      },
    );
  }
}