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

  /// Dipakai LaporanController untuk memperbarui satu baris tanpa
  /// membangun ulang seluruh objek secara manual (mis. menambah entri
  /// riwayat tindak lanjut). Field yang tidak diisi tetap memakai nilai
  /// lama.
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