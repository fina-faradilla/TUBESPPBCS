import 'package:flutter/material.dart';
import 'tindak_lanjut.dart';

class LaporanRow {
  final String id;
  final String judul;
  final String pelapor;
  final String kategori;
  final String status;
  final Color statusColor;
  final String tanggal;

  /// Field tambahan untuk halaman Detail Laporan.
  final String tingkatKerusakan; // Ringan / Sedang / Berat
  final String alamat;
  final String deskripsi;
  final String? fotoPath; // null = belum ada foto
  final double? lat; // null = belum ada titik lokasi
  final double? lng;
  final List<TindakLanjut> tindakLanjuts;

  const LaporanRow({
    required this.id,
    required this.judul,
    required this.pelapor,
    required this.kategori,
    required this.status,
    required this.statusColor,
    required this.tanggal,
    this.tingkatKerusakan = 'Sedang',
    this.alamat = '-',
    this.deskripsi = '-',
    this.fotoPath,
    this.lat,
    this.lng,
    this.tindakLanjuts = const [],
  });

  LaporanRow copyWith({
    String? id,
    String? judul,
    String? pelapor,
    String? kategori,
    String? status,
    Color? statusColor,
    String? tanggal,
    String? tingkatKerusakan,
    String? alamat,
    String? deskripsi,
    String? fotoPath,
    double? lat,
    double? lng,
    List<TindakLanjut>? tindakLanjuts,
  }) {
    return LaporanRow(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      pelapor: pelapor ?? this.pelapor,
      kategori: kategori ?? this.kategori,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      tanggal: tanggal ?? this.tanggal,
      tingkatKerusakan: tingkatKerusakan ?? this.tingkatKerusakan,
      alamat: alamat ?? this.alamat,
      deskripsi: deskripsi ?? this.deskripsi,
      fotoPath: fotoPath ?? this.fotoPath,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      tindakLanjuts: tindakLanjuts ?? this.tindakLanjuts,
    );
  }
}
