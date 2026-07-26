import 'package:flutter/foundation.dart' show kIsWeb;

class Api {
  // Otomatis pilih alamat servernya sesuai tempat aplikasi ini jalan:
  //
  // - Web (Chrome, dari `flutter run -d chrome`): browser & server Laravel
  //   sama-sama jalan di laptop ini, jadi `localhost` selalu benar dan
  //   TIDAK perlu diganti-ganti walau WiFi/IP laptop berubah-ubah.
  //
  // - HP fisik / non-web (Android/iOS): HP itu device terpisah, jadi harus
  //   pakai IP WiFi laptop (dari `ipconfig` -> "IPv4 Address" di adapter
  //   yang aktif), BUKAN localhost — localhost di HP artinya HP itu sendiri.
  //   Kalau IP laptop berubah (pindah/reconnect WiFi), update baris
  //   `_lanIp` di bawah ini.
  static const String _lanIp = '10.201.153.6';

  static const String baseUrl = kIsWeb
      ? 'http://localhost:8000/api'
      : 'http://$_lanIp:8000/api';

  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String logout = '$baseUrl/logout';
  static const String kategori = '$baseUrl/kategori';
}