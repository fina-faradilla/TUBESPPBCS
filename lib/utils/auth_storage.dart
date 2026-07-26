import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tempat tunggal untuk simpan/ambil/hapus token login.
///
/// CATATAN: print() di file ini SEMENTARA untuk debug masalah token,
/// hapus semua baris `debugPrint(...)` setelah masalahnya ketemu.
class AuthStorage {
  static const _key = 'auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(_key, token);
    debugPrint(
      '[AuthStorage] saveToken dipanggil. token="$token" berhasil=$ok',
    );
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_key);
    debugPrint('[AuthStorage] getToken dipanggil. hasil="$token"');
    return token;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    debugPrint('[AuthStorage] clearToken dipanggil.');
  }
}
