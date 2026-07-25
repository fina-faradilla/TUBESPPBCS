import 'package:flutter/foundation.dart';
import '../models/laporan_row.dart';
import '../utils/laporan_api.dart';

class LaporanController extends ChangeNotifier {
  LaporanController._internal();
  static final LaporanController instance = LaporanController._internal();

  List<LaporanRow> _rows = [];
  bool _loading = false;
  String? _error;
  bool _loadedOnce = false;

  List<LaporanRow> get rows => List.unmodifiable(_rows);
  bool get isLoading => _loading;
  String? get error => _error;

  int get total => _rows.length;
  int get menungguVerifikasi =>
      _rows.where((r) => r.status == 'Menunggu Verifikasi').length;
  int get sedangDiproses => _rows.where((r) => r.status == 'Diproses').length;
  int get selesai => _rows.where((r) => r.status == 'Selesai').length;
  List<LaporanRow> get terbaru => _rows.take(4).toList();

  LaporanRow? getById(String id) {
    for (final r in _rows) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Panggil sekali saat halaman admin pertama kali dibuka.
  Future<void> muatData({bool force = false}) async {
    if (_loadedOnce && !force) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _rows = await LaporanApi.fetchAll();
      _loadedOnce = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> tambahLaporan({
    required String judul,
    required String pelapor,
    required int kategoriId,
    required String status,
    required String tingkatKerusakan,
    required String alamat,
    required String deskripsi,
    double? lat,
    double? lng,
    List<int>? fotoBytes,
    String? fotoFileName,
  }) async {
    final created = await LaporanApi.create(
      judul: judul,
      pelapor: pelapor,
      kategoriId: kategoriId,
      status: status,
      tingkatKerusakan: tingkatKerusakan,
      alamat: alamat,
      deskripsi: deskripsi,
      lat: lat,
      lng: lng,
      fotoBytes: fotoBytes,
      fotoFileName: fotoFileName,
    );
    _rows.insert(0, created);
    notifyListeners();
  }

  Future<void> ubahLaporan(
    String id, {
    required String judul,
    required String pelapor,
    required int kategoriId,
    required String status,
    required String tingkatKerusakan,
    required String alamat,
    required String deskripsi,
    double? lat,
    double? lng,
  }) async {
    final updated = await LaporanApi.update(
      id,
      judul: judul,
      pelapor: pelapor,
      kategoriId: kategoriId,
      status: status,
      tingkatKerusakan: tingkatKerusakan,
      alamat: alamat,
      deskripsi: deskripsi,
      lat: lat,
      lng: lng,
    );
    final i = _rows.indexWhere((e) => e.id == id);
    if (i != -1) _rows[i] = updated;
    notifyListeners();
  }

  Future<void> verifikasiLaporan(String id) async {
    final updated = await LaporanApi.verifikasi(id);
    final idx = _rows.indexWhere((r) => r.id == id);
    if (idx != -1) _rows[idx] = updated;
    notifyListeners();
  }

  Future<void> hapusLaporan(String id) async {
    await LaporanApi.delete(id);
    _rows.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
