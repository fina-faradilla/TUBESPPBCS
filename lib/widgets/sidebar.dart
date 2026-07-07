import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Sidebar navigasi utama aplikasi.
///
/// Berbeda dari versi sebelumnya: sekarang setiap menu berpindah halaman
/// lewat NAMED ROUTE (`Navigator.pushReplacementNamed`), bukan lewat state
/// internal semacam enum. Ini supaya konsisten dengan gaya routing yang
/// dipakai tim untuk halaman publik (LandingPage, LoginPage, dll).
///
/// [currentRoute] adalah nama route yang sedang aktif (dikirim manual oleh
/// tiap halaman lewat ModalRoute.of(context)?.settings.name), dipakai untuk
/// menyorot menu yang sedang dibuka.
class Sidebar extends StatelessWidget {
  final String currentRoute;

  const Sidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppColors.sidebarBg,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'RF',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ROADFIX',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'JEMBATAN LAPOR JALAN\nRUSAK',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          const _SectionLabel('HALAMAN PUBLIK'),
          _NavItem(label: 'Beranda', route: '/', currentRoute: currentRoute),
          _NavItem(label: 'Masuk / Daftar', route: '/login', currentRoute: currentRoute),

          const SizedBox(height: 20),
          const _SectionLabel('PORTAL WARGA'),
          // TODO: ganti `route: null` menjadi nama route sesungguhnya
          // begitu halaman-halaman warga selesai dibuat oleh anggota tim lain.
          _NavItem(label: 'Buat Laporan', route: null, currentRoute: currentRoute),
          _NavItem(label: 'Riwayat Laporan Saya', route: null, currentRoute: currentRoute),
          _NavItem(label: 'Detail Laporan', route: null, currentRoute: currentRoute),

          const SizedBox(height: 20),
          const _SectionLabel('PORTAL ADMIN / DINAS'),
          _NavItem(label: 'Dashboard', route: '/admin/dashboard', currentRoute: currentRoute),
          _NavItem(label: 'Kelola Laporan', route: '/admin/manage-report', currentRoute: currentRoute),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final String? route; // null = halaman belum tersedia
  final String currentRoute;

  const _NavItem({
    required this.label,
    required this.route,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = route != null && route == currentRoute;
    final bool available = route != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? AppColors.gold : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () {
            if (!available) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Halaman ini belum tersedia.')),
              );
              return;
            }
            if (route == currentRoute) return; // sudah di halaman ini
            Navigator.of(context).pushReplacementNamed(route!);
          },
          child: Opacity(
            opacity: available ? 1 : 0.4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: active ? Colors.black : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      color: active ? Colors.black : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
