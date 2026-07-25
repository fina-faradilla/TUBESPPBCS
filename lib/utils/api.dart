class Api {
  // Pakai IP WiFi laptop (dari `ipconfig` -> "IPv4 Address" di adapter Wi-Fi)
  // kalau mau akses dari HP/device lain di jaringan yang sama.
  // Kalau cuma testing dari laptop ini sendiri, localhost sudah cukup.
  static const String baseUrl = 'http://localhost:8000/api';

  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String logout = '$baseUrl/logout';
  static const String kategori = '$baseUrl/kategori';
}
