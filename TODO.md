# TODO: Fix Autentikasi & CRUD Laporan

## Steps

- [x] 1. **main.dart** — Ubah import LoginPage dari `screens/public/login_page.dart` ke `screens/auth/login_page.dart`
- [x] 2. **register_page.dart** — Hubungkan form register ke API backend (POST /api/register), simpan token, redirect ke dashboard
- [x] 3. **sidebar.dart** — Panggil `AuthStorage.clearToken()` sebelum navigasi logout ke landing page
- [x] 4. Jalankan `flutter pub get` & `flutter analyze` (tidak ada error)
