import 'package:flutter/foundation.dart';
import '../models/kategori.dart';
import '../utils/status_utils.dart';

/// Sumber data kategori bersama (in-memory), mengikuti pola yang sama
/// dengan [LaporanController]: singleton + ChangeNotifier, supaya nanti
/// tinggal diganti isinya untuk memanggil API Laravel yang sesungguhnya
/// tanpa mengubah widget yang memakainya.
class KategoriController extends ChangeNotifier {
  KategoriController._internal();

  static final KategoriController instance = KategoriController._internal();

  // Diseed dari kKategoriOptions (status_utils.dart) supaya konsisten
  // dengan dropdown kategori yang sudah dipakai di form Laporan.
  final List<Kategori> _rows = [
    for (int i = 0; i < kKategoriOptions.length; i++)
      Kategori(
        id: 'KTG-${(i + 1).toString().padLeft(4, '0')}',
        nama: kKategoriOptions[i],
      ),
  ];

  int _sequence = 4;

  List<Kategori> get rows => List.unmodifiable(_rows);
  int get total => _rows.length;

  Kategori? getById(String id) {
    for (final k in _rows) {
      if (k.id == id) return k;
    }
    return null;
  }

  String _generateId() {
    _sequence += 1;
    return 'KTG-${_sequence.toString().padLeft(4, '0')}';
  }

  /// Create
  void tambahKategori({required String nama, String deskripsi = '-'}) {
    _rows.add(Kategori(id: _generateId(), nama: nama, deskripsi: deskripsi));
    notifyListeners();
  }

  /// Update
  void ubahKategori(String id, {required String nama, String? deskripsi}) {
    final index = _rows.indexWhere((k) => k.id == id);
    if (index == -1) return;
    _rows[index] = _rows[index].copyWith(nama: nama, deskripsi: deskripsi);
    notifyListeners();
  }

  /// Delete
  void hapusKategori(String id) {
    _rows.removeWhere((k) => k.id == id);
    notifyListeners();
  }
}