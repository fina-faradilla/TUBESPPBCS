import 'package:flutter/foundation.dart';
import '../models/kategori.dart';
import '../utils/kategori_api.dart';

/// Sumber data kategori bersama, mengikuti pola yang sama dengan
/// [LaporanController]: singleton + ChangeNotifier, dibaca lewat
/// endpoint `/api/kategori` (GET) dan dikelola lewat `/api/admin/kategori`
/// (POST/PUT/DELETE).
class KategoriController extends ChangeNotifier {
  KategoriController._internal();

  static final KategoriController instance = KategoriController._internal();

  List<Kategori> _rows = [];
  bool _loading = false;
  String? _error;
  bool _loadedOnce = false;

  List<Kategori> get rows => List.unmodifiable(_rows);
  bool get isLoading => _loading;
  String? get error => _error;
  int get total => _rows.length;

  /// Daftar nama kategori saja, dipakai oleh dropdown di form Laporan
  /// dan filter di Kelola Laporan — supaya keduanya selalu sinkron
  /// dengan data yang dikelola lewat halaman Kelola Kategori.
  List<String> get namaList => _rows.map((k) => k.nama).toList();

  Kategori? getById(int id) {
    for (final k in _rows) {
      if (k.id == id) return k;
    }
    return null;
  }

  /// Panggil sekali saat halaman Kelola Kategori pertama kali dibuka.
  Future<void> muatData({bool force = false}) async {
    if (_loadedOnce && !force) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _rows = await KategoriApi.fetchAllFull();
      _loadedOnce = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Create
  Future<void> tambahKategori({
    required String nama,
    String deskripsi = '-',
  }) async {
    final created = await KategoriApi.create(nama: nama, deskripsi: deskripsi);
    _rows.add(created);
    notifyListeners();
  }

  /// Update
  Future<void> ubahKategori(
    int id, {
    required String nama,
    String? deskripsi,
  }) async {
    final updated = await KategoriApi.update(
      id,
      nama: nama,
      deskripsi: deskripsi ?? '-',
    );
    final index = _rows.indexWhere((k) => k.id == id);
    if (index != -1) _rows[index] = updated;
    notifyListeners();
  }

  /// Delete
  Future<void> hapusKategori(int id) async {
    await KategoriApi.delete(id);
    _rows.removeWhere((k) => k.id == id);
    notifyListeners();
  }
}