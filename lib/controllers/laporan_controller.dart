import 'package:flutter/foundation.dart';
import '../models/laporan_row.dart';
import '../utils/status_utils.dart';

/// Sumber data laporan bersama (in-memory).
///
/// Dibuat sebagai SINGLETON (satu-satunya instance untuk seluruh aplikasi)
/// karena halaman Dashboard dan Kelola Laporan sekarang dinavigasi lewat
/// named route terpisah (bukan lagi lewat satu shell/parent widget), jadi
/// keduanya perlu mengambil instance yang SAMA supaya data selalu sinkron.
/// Panggil lewat `LaporanController.instance` di mana pun dibutuhkan.
///
/// Nantinya ketika sudah ada backend/API, method-method di controller ini
/// tinggal diganti isinya untuk memanggil data source yang sesungguhnya
/// (mis. HTTP request), sedangkan semua widget yang memakai controller ini
/// tidak perlu berubah.
class LaporanController extends ChangeNotifier {
  LaporanController._internal();

  /// Satu-satunya instance yang dipakai di seluruh aplikasi.
  static final LaporanController instance = LaporanController._internal();

  final List<LaporanRow> _rows = [
    LaporanRow(
      id: 'JK-0143',
      judul: 'Jalan Berlubang Besar',
      pelapor: 'Desti R.',
      kategori: 'Berlubang',
      status: 'BARU',
      statusColor: statusColorFor('BARU'),
      tanggal: '03 Jul 2026',
    ),
    LaporanRow(
      id: 'JK-0142',
      judul: 'Aspal Retak Parah',
      pelapor: 'Fina F.',
      kategori: 'Retak',
      status: 'DIPROSES',
      statusColor: statusColorFor('DIPROSES'),
      tanggal: '29 Jun 2026',
    ),
    LaporanRow(
      id: 'JK-0141',
      judul: 'Jembatan Rusak',
      pelapor: 'Gita R.',
      kategori: 'Jembatan',
      status: 'DIVERIFIKASI',
      statusColor: statusColorFor('DIVERIFIKASI'),
      tanggal: '25 Jun 2026',
    ),
    LaporanRow(
      id: 'JK-0140',
      judul: 'Jalan Ambles Sebagian',
      pelapor: 'Aisyiyah Z.',
      kategori: 'Ambles',
      status: 'SELESAI',
      statusColor: statusColorFor('SELESAI'),
      tanggal: '18 Jun 2026',
    ),
  ];

  int _sequence = 143;

  /// Read: daftar semua laporan (urut terbaru dulu).
  List<LaporanRow> get rows => List.unmodifiable(_rows);

  int get total => _rows.length;
  int get menungguVerifikasi => _rows.where((r) => r.status == 'BARU').length;
  int get sedangDiproses => _rows.where((r) => r.status == 'DIPROSES').length;
  int get selesai => _rows.where((r) => r.status == 'SELESAI').length;

  /// 4 laporan paling baru untuk ditampilkan di dashboard.
  List<LaporanRow> get terbaru => _rows.take(4).toList();

  String _generateId() {
    _sequence += 1;
    return 'JK-${_sequence.toString().padLeft(4, '0')}';
  }

  /// Create
  void tambahLaporan({
    required String judul,
    required String pelapor,
    required String kategori,
    required String status,
    required String tanggal,
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
