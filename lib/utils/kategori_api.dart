import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/kategori_option.dart';
import 'api.dart';
import 'auth_storage.dart';

/// Mengambil & mengelola kategori dari backend. Endpoint dasar:
/// `Api.kategori` -> `/api/kategori`.
class KategoriApi {
  static Future<Map<String, String>> _authHeaders({bool json = false}) async {
    final token = await AuthStorage.getToken();
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<KategoriOption>> fetchAll() async {
    final res = await http.get(
      Uri.parse(Api.kategori),
      headers: await _authHeaders(),
    );
    _throwIfError(res);
    final List data = jsonDecode(res.body) as List;
    return data
        .map((e) => KategoriOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<KategoriOption> create({
    required String nama,
    String? deskripsi,
  }) async {
    final res = await http.post(
      Uri.parse(Api.kategori),
      headers: await _authHeaders(json: true),
      body: jsonEncode({
        'nama_kategori': nama,
        if (deskripsi != null) 'deskripsi': deskripsi,
      }),
    );
    _throwIfError(res);
    return KategoriOption.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<KategoriOption> update(
    int id, {
    required String nama,
    String? deskripsi,
  }) async {
    final res = await http.put(
      Uri.parse('${Api.kategori}/$id'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({
        'nama_kategori': nama,
        if (deskripsi != null) 'deskripsi': deskripsi,
      }),
    );
    _throwIfError(res);
    return KategoriOption.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<void> delete(int id) async {
    final res = await http.delete(
      Uri.parse('${Api.kategori}/$id'),
      headers: await _authHeaders(),
    );
    _throwIfError(res);
  }

  static void _throwIfError(http.Response res) {
    if (res.statusCode >= 400) {
      String message = 'Terjadi kesalahan (${res.statusCode})';
      try {
        final body = jsonDecode(res.body);
        debugPrint('[KategoriApi] Error response body: $body');
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
        debugPrint('[KategoriApi] Gagal parse error body: ${res.body}');
      }
      throw Exception(message);
    }
  }
}