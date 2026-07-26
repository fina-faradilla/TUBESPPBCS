import 'package:flutter/foundation.dart';
import '../models/laporan_row.dart';
import '../utils/warga_laporan_api.dart';

/// State management untuk Portal Warga, meniru pola [LaporanController]
/// di Portal Admin — dipakai bersama oleh RiwayatLaporanScreen (daftar)
/// dan DetailLaporanScreen (detail), supaya keduanya berbagi data yang
/// sama tanpa perlu fetch berulang-ulang.
class WargaLaporanController extends ChangeNotifier {
  WargaLaporanController._internal();
  static final WargaLaporanController instance =
      WargaLaporanController._internal();

  List<LaporanRow> _rows = [];
  bool _loading = false;
  String? _error;
  bool _loadedOnce = false;

  List<LaporanRow> get rows => List.unmodifiable(_rows);
  bool get isLoading => _loading;
  String? get error => _error;
  int get total => _rows.length;

  /// Ambil dari cache daftar yang sudah dimuat (dipakai sebagai fallback
  /// cepat sebelum/pada saat detail lengkap sedang di-fetch).
  LaporanRow? getById(String id) {
    for (final r in _rows) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Panggil sekali saat halaman Riwayat Laporan pertama kali dibuka.
  Future<void> muatData({bool force = false}) async {
    if (_loadedOnce && !force) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _rows = await WargaLaporanApi.fetchMine();
      _loadedOnce = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Ambil detail satu laporan langsung dari server (termasuk riwayat
  /// tindak lanjut terbaru). Kalau gagal (mis. endpoint belum ada di
  /// backend) dan datanya sudah ada di cache [rows], pakai itu saja
  /// supaya halaman detail tetap bisa tampil.
  Future<LaporanRow?> muatDetail(String id) async {
    try {
      final detail = await WargaLaporanApi.fetchById(id);
      final idx = _rows.indexWhere((r) => r.id == id);
      if (idx != -1) {
        _rows[idx] = detail;
      } else {
        _rows.add(detail);
      }
      notifyListeners();
      return detail;
    } catch (_) {
      return getById(id);
    }
  }
}
