import 'package:flutter/material.dart';

class LaporanRow {
  final String id;
  final String judul;
  final String pelapor;
  final String kategori;
  final String status;
  final Color statusColor;
  final String tanggal;

  const LaporanRow({
    required this.id,
    required this.judul,
    required this.pelapor,
    required this.kategori,
    required this.status,
    required this.statusColor,
    required this.tanggal,
  });

  LaporanRow copyWith({
    String? id,
    String? judul,
    String? pelapor,
    String? kategori,
    String? status,
    Color? statusColor,
    String? tanggal,
  }) {
    return LaporanRow(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      pelapor: pelapor ?? this.pelapor,
      kategori: kategori ?? this.kategori,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      tanggal: tanggal ?? this.tanggal,
    );
  }
}
