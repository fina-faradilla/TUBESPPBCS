import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/kategori_option.dart';
import 'api.dart';
import 'auth_storage.dart';

class KategoriApi {
  static Uri _u(String path) => Uri.parse('${Api.baseUrl}$path');

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
}
