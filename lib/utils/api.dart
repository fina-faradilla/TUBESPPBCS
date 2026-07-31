class Api {
  // static const String baseUrl = 'http://127.0.0.1:8000/api';

  static const String baseUrl = 'http://10.254.173.52:8000/api';
  // Pakai IP WiFi laptop (dari `ipconfig` -> "IPv4 Address" di adapter Wi-Fi),
  // BUKAN 127.0.0.1 / localhost, karena itu hanya bisa diakses dari laptop
  // itu sendiri (Chrome/desktop), tidak bisa dari HP fisik yang beda device.
  //
  // Kalau IP laptop berubah (misal pindah WiFi), jalankan `ipconfig` lagi
  // dan update baris ini.
  // static const String baseUrl = 'http://10.201.153.178:8000/api';

  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String logout = '$baseUrl/logout';
  static const String kategori = '$baseUrl/kategori';
}