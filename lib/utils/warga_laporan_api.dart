import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/laporan_row.dart';
import 'api.dart';
import 'auth_storage.dart';

/// Endpoint /api/laporan (BUKAN /api/admin/laporan) — khusus Portal Warga,
/// otomatis dibatasi ke laporan milik user yang login (lihat controller
/// Laravel-nya: App\Http\Controllers\Api\LaporanApiController).
class WargaLaporanApi {
  static Uri _u(String path) => Uri.parse('${Api.baseUrl}/laporan$path');

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Riwayat laporan milik user yang sedang login.
  static Future<List<LaporanRow>> fetchMine() async {
    final res = await http.get(_u(''), headers: await _authHeaders());
    _throwIfError(res);
    final List data = jsonDecode(res.body) as List;
    return data
        .map((e) => LaporanRow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Detail satu laporan (GET /api/laporan/{id}) — dipakai halaman
  /// Detail Laporan warga supaya dapat data ter-update termasuk
  /// riwayat tindak lanjut, tanpa perlu muat ulang seluruh daftar.
  ///
  /// Kalau endpoint detail ini belum ada di backend, halaman detail akan
  /// otomatis fallback memakai data dari [fetchMine] yang sudah di-cache
  /// (lihat WargaLaporanController.getById).
  static Future<LaporanRow> fetchById(String id) async {
    final numericId = id.replaceAll(RegExp(r'[^0-9]'), '');
    final res = await http.get(_u('/$numericId'), headers: await _authHeaders());
    _throwIfError(res);
    return LaporanRow.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// Buat laporan baru. Status otomatis "Menunggu Verifikasi" dari
  /// backend — warga tidak bisa set status sendiri.
  static Future<LaporanRow> create({
    required String judul,
    required int kategoriId,
    required String tingkatKerusakan,
    required String deskripsi,
    required String alamat,
    required double lat,
    required double lng,
    List<int>? fotoBytes,
    String? fotoFileName,
  }) async {
    final token = await AuthStorage.getToken();

    final request = http.MultipartRequest('POST', _u(''))
      ..headers['Accept'] = 'application/json'
      ..fields['judul'] = judul
      ..fields['kategori_id'] = kategoriId.toString()
      ..fields['tingkat_kerusakan'] = tingkatKerusakan
      ..fields['deskripsi'] = deskripsi
      ..fields['alamat'] = alamat
      ..fields['latitude'] = lat.toString()
      ..fields['longitude'] = lng.toString();

    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    if (fotoBytes != null && fotoFileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes('foto', fotoBytes, filename: fotoFileName),
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    _throwIfError(res);
    return LaporanRow.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static void _throwIfError(http.Response res) {
    if (res.statusCode >= 400) {
      String message = 'Terjadi kesalahan (${res.statusCode})';
      try {
        final body = jsonDecode(res.body);
        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        }
        if (body is Map && body['errors'] is Map) {
          final errors = body['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstError = (errors.values.first as List).first;
            message = firstError.toString();
          }
        }
      } catch (_) {}
      throw Exception(message);
    }
  }
}
