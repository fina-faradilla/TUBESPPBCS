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
      _rows.where((r) => r.status == 'Menunggu').length;
  int get sedangDiproses => _rows.where((r) => r.status == 'Diproses').length;
  int get selesai => _rows.where((r) => r.status == 'Selesai').length;
  List<LaporanRow> get terbaru => _rows.take(4).toList();

  static const List<String> _bulanPendek = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  /// Jumlah laporan per bulan untuk 6 bulan terakhir (termasuk bulan
  /// berjalan), dihitung dari tanggal laporan yang sebenarnya di database —
  /// bukan lagi angka contoh/dummy.
  List<int> get trenBulananValues => _trenBulanan().$1;

  /// Label bulan (mis. "Feb", "Mar", ...) yang berpasangan dengan
  /// [trenBulananValues].
  List<String> get trenBulananLabels => _trenBulanan().$2;

  (List<int>, List<String>) _trenBulanan() {
    final now = DateTime.now();
    // 6 bulan terakhir, dari yang paling lama ke bulan berjalan.
    final bulanTarget = List.generate(
      6,
      (i) => DateTime(now.year, now.month - (5 - i)),
    );

    final counts = List<int>.filled(6, 0);
    for (final row in _rows) {
      final tgl = _parseTanggal(row.tanggal);
      if (tgl == null) continue;
      for (int i = 0; i < bulanTarget.length; i++) {
        if (tgl.year == bulanTarget[i].year &&
            tgl.month == bulanTarget[i].month) {
          counts[i]++;
          break;
        }
      }
    }

    final labels = bulanTarget.map((d) => _bulanPendek[d.month - 1]).toList();
    return (counts, labels);
  }

  /// Parse format tanggal dari backend: "dd MMM yyyy" (mis. "07 Jul 2026"),
  /// sama seperti yang dipakai di [status_utils.formatTanggal].
  DateTime? _parseTanggal(String tanggal) {
    final parts = tanggal.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final monthIndex = _bulanPendek.indexOf(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || monthIndex == -1 || year == null) return null;
    return DateTime(year, monthIndex + 1, day);
  }

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

  /// Tambah satu entri riwayat tindak lanjut ke laporan [laporanId].
  /// Dipanggil dari tab "Riwayat Tindak Lanjut" di halaman Detail Laporan.
  /// Dikirim ke backend (bukan cuma diubah di state lokal) supaya warga
  /// yang bersangkutan juga bisa lihat perkembangannya.
  Future<void> tambahTindakLanjut(
    String laporanId, {
    required String status,
    required String catatan,
  }) async {
    final updated = await LaporanApi.tambahTindakLanjut(
      laporanId,
      status: status,
      catatan: catatan,
    );
    final index = _rows.indexWhere((r) => r.id == laporanId);
    if (index != -1) _rows[index] = updated;
    notifyListeners();
  }
}