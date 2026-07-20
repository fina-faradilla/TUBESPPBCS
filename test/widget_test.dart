// Basic smoke test untuk aplikasi RoadFix.
//
// Test ini memastikan:
// 1. Aplikasi bisa dibangun (build) tanpa error dan Landing Page tampil
//    sebagai halaman awal (initialRoute: '/').
// 2. Halaman admin (Dashboard & Kelola Laporan) juga bisa dibangun tanpa
//    error saat dibuka langsung (keduanya sekarang dinavigasi lewat named
//    route '/admin/dashboard' dan '/admin/manage-report').

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tubesppbcs/main.dart';
import 'package:tubesppbcs/screens/admin/dashboard_page.dart';
import 'package:tubesppbcs/screens/admin/manage_report_page.dart';

void main() {
  testWidgets('RoadFix menampilkan Landing Page saat pertama dibuka',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RoadFixApp());

    // Landing page menampilkan nama aplikasi "ROADFIX" di app bar.
    expect(find.text('ROADFIX'), findsOneWidget);

    // Tombol "Masuk" dan "Daftar" harus ada di landing page.
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
  });

  testWidgets('DashboardPage menampilkan judul DASHBOARD',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardPage()));

    expect(find.text('DASHBOARD'), findsOneWidget);
  });

  testWidgets('ManageReportPage menampilkan judul KELOLA LAPORAN',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ManageReportPage()));

    expect(find.text('KELOLA LAPORAN'), findsOneWidget);
  });
}
