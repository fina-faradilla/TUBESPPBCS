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

  final String tingkatKerusakan;
  final String alamat;
  final String deskripsi;
  final String? fotoPath;
  final double? lat;
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
    required this.tingkatKerusakan,
    required this.alamat,
    required this.deskripsi,
    this.fotoPath,
    this.lat,
    this.lng,
    this.tindakLanjuts = const [],
  });

  factory LaporanRow.fromJson(Map<String, dynamic> json) {
    Color warna;

    // Disamakan persis dengan nilai status yang dipakai
    // LaporanApiController (Laravel): 'Menunggu Verifikasi', 'Diproses',
    // 'Selesai'. Sebelumnya case pertama tertulis 'Menunggu' saja sehingga
    // tidak pernah cocok dan selalu jatuh ke warna abu-abu (default).
    switch (json['status']) {
      case 'Menunggu Verifikasi':
        warna = Colors.orange;
        break;
      case 'Diproses':
        warna = Colors.blue;
        break;
      case 'Selesai':
        warna = Colors.green;
        break;
      default:
        warna = Colors.grey;
    }

    return LaporanRow(
      id: json['id'].toString(),
      judul: json['judul'] ?? '',
      pelapor: json['pelapor'] ?? '-',
      kategori: json['kategori'] ?? '-',
      status: json['status'] ?? '',
      statusColor: warna,
      tanggal: json['tanggal'] ?? '',
      tingkatKerusakan: json['tingkat_kerusakan'] ?? '',
      alamat: json['alamat'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      fotoPath: json['foto_url'],
      lat: (json['latitude'] as num?)?.toDouble(),
      lng: (json['longitude'] as num?)?.toDouble(),
    );
  }
}