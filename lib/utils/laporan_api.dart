import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/laporan_row.dart';
import 'api.dart';
import 'auth_storage.dart';

class LaporanApi {
  static Uri _u(String path) => Uri.parse('${Api.baseUrl}/admin/laporan$path');

  static String _numericId(String id) => id.replaceAll(RegExp(r'[^0-9]'), '');

  static Future<Map<String, String>> _authHeaders({bool json = false}) async {
    final token = await AuthStorage.getToken();
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<LaporanRow>> fetchAll() async {
    final res = await http.get(_u(''), headers: await _authHeaders());
    _throwIfError(res);
    final List data = jsonDecode(res.body) as List;
    return data
        .map((e) => LaporanRow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<LaporanRow> create({
    required String judul,
    required String pelapor,
    required int kategoriId,
    required String tingkatKerusakan,
    required String status,
    required String deskripsi,
    required String alamat,
    double? lat,
    double? lng,
    List<int>? fotoBytes,
    String? fotoFileName,
  }) async {
    final token = await AuthStorage.getToken();

    final request = http.MultipartRequest('POST', _u(''))
      ..headers['Accept'] = 'application/json'
      ..fields['judul'] = judul
      ..fields['pelapor'] = pelapor
      ..fields['kategori_id'] = kategoriId.toString()
      ..fields['tingkat_kerusakan'] = tingkatKerusakan
      ..fields['status'] = status
      ..fields['deskripsi'] = deskripsi
      ..fields['alamat'] = alamat;

    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (lat != null) request.fields['latitude'] = lat.toString();
    if (lng != null) request.fields['longitude'] = lng.toString();

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

  static Future<LaporanRow> update(
    String id, {
    required String judul,
    required String pelapor,
    required int kategoriId,
    required String tingkatKerusakan,
    required String status,
    required String deskripsi,
    required String alamat,
    double? lat,
    double? lng,
  }) async {
    final res = await http.put(
      _u('/${_numericId(id)}'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({
        'judul': judul,
        'pelapor': pelapor,
        'kategori_id': kategoriId,
        'tingkat_kerusakan': tingkatKerusakan,
        'status': status,
        'deskripsi': deskripsi,
        'alamat': alamat,
        if (lat != null) 'latitude': lat,
        if (lng != null) 'longitude': lng,
      }),
    );
    _throwIfError(res);
    return LaporanRow.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<LaporanRow> verifikasi(String id) async {
    final res = await http.patch(
      _u('/${_numericId(id)}/verifikasi'),
      headers: await _authHeaders(),
    );
    _throwIfError(res);
    return LaporanRow.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<void> delete(String id) async {
    final res = await http.delete(
      _u('/${_numericId(id)}'),
      headers: await _authHeaders(),
    );
    _throwIfError(res);
  }

  static void _throwIfError(http.Response res) {
    if (res.statusCode >= 400) {
      String message = 'Terjadi kesalahan (${res.statusCode})';
      try {
        final body = jsonDecode(res.body);
        debugPrint('[LaporanApi] Error response body: $body');
        if (body is Map) {
          if (body['message'] != null) {
            message = body['message'].toString();
          }
          if (body['errors'] is Map) {
            final errors = body['errors'] as Map;
            final detail = errors.values
                .map((e) => e is List ? e.join(', ') : e.toString())
                .join('; ');
            message += ' | $detail';
          }
        }
      } catch (e) {
        debugPrint('[LaporanApi] Gagal parse error body: ${res.body}');
      }
      debugPrint('[LaporanApi] throw Exception: $message');
      throw Exception(message);
    }
  }
}
