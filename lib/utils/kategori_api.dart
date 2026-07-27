import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/kategori.dart';
import '../models/kategori_option.dart';
import 'api.dart';
import 'auth_storage.dart';

class KategoriApi {
  static Uri _u(String path) => Uri.parse('${Api.baseUrl}$path');
  static Uri _admin(String path) => Uri.parse('${Api.baseUrl}/admin/kategori$path');

  static Future<Map<String, String>> _authHeaders({bool json = false}) async {
    final token = await AuthStorage.getToken();
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Ambil daftar kategori dari endpoint `/api/kategori`.
  static Future<List<KategoriOption>> fetchAll() async {
    final token = await AuthStorage.getToken();
    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.get(_u('/kategori'), headers: headers);
    if (res.statusCode >= 400) {
      debugPrint('[KategoriApi] Error: ${res.statusCode} ${res.body}');
      throw Exception('Gagal memuat kategori (${res.statusCode})');
    }

    // Backend bisa mengembalikan array langsung atau terbungkus `data`
    final decoded = jsonDecode(res.body);
    final List list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map && decoded['data'] is List) {
      list = decoded['data'] as List;
    } else {
      throw Exception('Format response kategori tidak dikenali');
    }

    return list
        .map((e) => KategoriOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sama seperti [fetchAll], tapi mengembalikan model [Kategori] yang
  /// lengkap (termasuk deskripsi) — dipakai halaman Kelola Kategori.
  static Future<List<Kategori>> fetchAllFull() async {
    final res = await http.get(_u('/kategori'), headers: await _authHeaders());
    _throwIfError(res);

    final decoded = jsonDecode(res.body);
    final List list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map && decoded['data'] is List) {
      list = decoded['data'] as List;
    } else {
      throw Exception('Format response kategori tidak dikenali');
    }

    return list.map((e) => Kategori.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Kategori> create({
    required String nama,
    required String deskripsi,
  }) async {
    final res = await http.post(
      _admin(''),
      headers: await _authHeaders(json: true),
      body: jsonEncode({'nama_kategori': nama, 'deskripsi': deskripsi}),
    );
    _throwIfError(res);
    return Kategori.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<Kategori> update(
    int id, {
    required String nama,
    required String deskripsi,
  }) async {
    final res = await http.put(
      _admin('/$id'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({'nama_kategori': nama, 'deskripsi': deskripsi}),
    );
    _throwIfError(res);
    return Kategori.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<void> delete(int id) async {
    final res = await http.delete(_admin('/$id'), headers: await _authHeaders());
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
      debugPrint('[KategoriApi] throw Exception: $message');
      throw Exception(message);
    }
  }
}
