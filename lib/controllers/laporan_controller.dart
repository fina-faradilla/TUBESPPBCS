import 'package:flutter/foundation.dart';
import '../models/laporan_row.dart';
import '../models/tindak_lanjut.dart';
import '../utils/status_utils.dart';

/// Sumber data laporan bersama (in-memory).
///
/// Dibuat sebagai SINGLETON (satu-satunya instance untuk seluruh aplikasi)
/// karena halaman Dashboard, Kelola Laporan, dan Detail Laporan dinavigasi
/// lewat named route terpisah (bukan lewat satu shell/parent widget), jadi
/// semuanya perlu mengambil instance yang SAMA supaya data selalu sinkron.
/// Panggil lewat `LaporanController.instance` di mana pun dibutuhkan.
///
/// Nantinya ketika sudah ada backend/API, method-method di controller ini
/// tinggal diganti isinya untuk memanggil data source yang sesungguhnya
/// (mis. HTTP request ke endpoint Laravel), sedangkan semua widget yang
/// memakai controller ini tidak perlu berubah.
class LaporanController extends ChangeNotifier {
  LaporanController._internal();

  /// Satu-satunya instance yang dipakai di seluruh aplikasi.
  static final LaporanController instance = LaporanController._internal();

  final List<LaporanRow> _rows = [
    LaporanRow(
      id: 'RF-0001',
      judul: 'Jalan Berlubang Besar',
      pelapor: 'Desti R.',
      kategori: 'Berlubang',
      status: 'Menunggu Verifikasi',
      statusColor: statusColorFor('Menunggu Verifikasi'),
      tanggal: '13 Jul 2026',
      tingkatKerusakan: 'Berat',
      alamat: 'Jl. Merdeka No. 12, Bandung',
      deskripsi:
          'Lubang cukup dalam dan membahayakan pengendara motor pada malam hari.',
      lat: -6.9147,
      lng: 107.6098,
    ),
    LaporanRow(
      id: 'RF-0002',
      judul: 'Aspal Retak Parah',
      pelapor: 'Fina F.',
      kategori: 'Retak',
      status: 'Diproses',
      statusColor: statusColorFor('Diproses'),
      tanggal: '13 Jul 2026',
      tingkatKerusakan: 'Sedang',
      alamat: 'Jl. Asia Afrika, Bandung',
      deskripsi: 'Retakan memanjang sekitar 5 meter di sisi kiri jalan.',
      lat: -6.9218,
      lng: 107.6070,
    ),
    LaporanRow(
      id: 'RF-0003',
      judul: 'Jembatan Rusak',
      pelapor: 'Gita R.',
      kategori: 'Jembatan',
      status: 'Diproses',
      statusColor: statusColorFor('Diproses'),
      tanggal: '13 Jul 2026',
      tingkatKerusakan: 'Berat',
      alamat: 'Jl. Soekarno Hatta, Bandung',
      deskripsi: 'Sebagian pagar pembatas jembatan roboh.',
      // Contoh laporan yang sudah punya titik lokasi, supaya peta di halaman
      // Detail Laporan langsung tampil.
      lat: -6.9004,
      lng: 107.6187,
      tindakLanjuts: [
        TindakLanjut(
          id: 1,
          judul: 'Laporan diverifikasi',
          keterangan:
              'Petugas telah meninjau lokasi dan mengonfirmasi kerusakan.',
          createdAt: DateTime(2026, 7, 14),
        ),
        TindakLanjut(
          id: 2,
          judul: 'Tim teknis dikirim',
          keterangan:
              'Tim Dinas PU dijadwalkan turun ke lokasi untuk perbaikan sementara.',
          createdAt: DateTime(2026, 7, 15),
        ),
      ],
    ),
    LaporanRow(
      id: 'RF-0004',
      judul: 'Jalan Ambles Sebagian',
      pelapor: 'Aisyiyah Z.',
      kategori: 'Ambles',
      status: 'Selesai',
      statusColor: statusColorFor('Selesai'),
      tanggal: '13 Jul 2026',
      tingkatKerusakan: 'Ringan',
      alamat: 'Jl. Dago, Bandung',
      deskripsi: 'Penurunan permukaan jalan sekitar 5 cm, sudah ditangani.',
      lat: -6.8951,
      lng: 107.6134,
    ),
  ];

  int _sequence = 4;

  /// Read: daftar semua laporan (urut terbaru dulu).
  List<LaporanRow> get rows => List.unmodifiable(_rows);

  int get total => _rows.length;
  int get menungguVerifikasi =>
      _rows.where((r) => r.status == 'Menunggu Verifikasi').length;
  int get sedangDiproses => _rows.where((r) => r.status == 'Diproses').length;
  int get selesai => _rows.where((r) => r.status == 'Selesai').length;

  /// 4 laporan paling baru untuk ditampilkan di dashboard.
  List<LaporanRow> get terbaru => _rows.take(4).toList();

  /// Cari 1 laporan berdasarkan ID (dipakai halaman Detail Laporan).
  LaporanRow? getById(String id) {
    for (final r in _rows) {
      if (r.id == id) return r;
    }
    return null;
  }

  String _generateId() {
    _sequence += 1;
    return 'RF-${_sequence.toString().padLeft(4, '0')}';
  }

  /// Create
  void tambahLaporan({
    required String judul,
    required String pelapor,
    required String kategori,
    required String status,
    required String tanggal,
    String tingkatKerusakan = 'Sedang',
    String alamat = '-',
    String deskripsi = '-',
  }) {
    _rows.insert(
      0,
      LaporanRow(
        id: _generateId(),
        judul: judul,
        pelapor: pelapor,
        kategori: kategori,
        status: status,
        statusColor: statusColorFor(status),
        tanggal: tanggal,
        tingkatKerusakan: tingkatKerusakan,
        alamat: alamat,
        deskripsi: deskripsi,
      ),
    );
    notifyListeners();
  }

  /// Update
  void ubahLaporan(
    String id, {
    required String judul,
    required String pelapor,
    required String kategori,
    required String status,
    required String tanggal,
    String? tingkatKerusakan,
    String? alamat,
    String? deskripsi,
  }) {
    final index = _rows.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _rows[index] = _rows[index].copyWith(
      judul: judul,
      pelapor: pelapor,
      kategori: kategori,
      status: status,
      statusColor: statusColorFor(status),
      tanggal: tanggal,
      tingkatKerusakan: tingkatKerusakan,
      alamat: alamat,
      deskripsi: deskripsi,
    );
    notifyListeners();
  }

  /// Update cepat khusus status (dipakai tombol "Verifikasi").
  void ubahStatus(String id, String status) {
    final index = _rows.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _rows[index] = _rows[index].copyWith(
      status: status,
      statusColor: statusColorFor(status),
    );
    notifyListeners();
  }

  /// Delete
  void hapusLaporan(String id) {
    _rows.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
