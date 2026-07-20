import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Sidebar navigasi utama aplikasi (khusus area Portal Admin/Dinas).
///
/// Perpindahan halaman lewat NAMED ROUTE (`Navigator.pushReplacementNamed`),
/// konsisten dengan gaya routing yang dipakai tim.
///
/// [currentRoute] adalah nama route yang sedang aktif (dikirim manual oleh
/// tiap halaman lewat ModalRoute.of(context)?.settings.name), dipakai untuk
/// menyorot menu yang sedang dibuka.
///
/// Sidebar ini punya tombol collapse/expand (ikon panah bulat di kanan atas,
/// seperti pada versi web) yang menyembunyikan label teks dan hanya
/// menyisakan ikon menu, supaya konten utama punya ruang lebih lebar.
class Sidebar extends StatefulWidget {
  final String currentRoute;

  const Sidebar({super.key, required this.currentRoute});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final double width = _collapsed ? 84 : 240;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      color: AppColors.sidebarBg,
      padding: EdgeInsets.symmetric(
        vertical: 24,
        horizontal: _collapsed ? 14 : 16,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Row(
                mainAxisAlignment: _collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
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
                  if (!_collapsed) ...[
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
                ],
              ),
              const SizedBox(height: 28),

              if (!_collapsed) const _SectionLabel('PORTAL ADMIN / DINAS'),
              _NavItem(
                label: 'Dashboard',
                icon: Icons.bar_chart_rounded,
                route: '/admin/dashboard',
                currentRoute: widget.currentRoute,
                collapsed: _collapsed,
              ),
              _NavItem(
                label: 'Kelola Laporan',
                icon: Icons.assignment_outlined,
                route: '/admin/manage-report',
                currentRoute: widget.currentRoute,
                collapsed: _collapsed,
              ),
              // TODO: sesuaikan nama route ini dengan route halaman
              // "Kelola Kategori" yang sesungguhnya begitu tersedia.
              _NavItem(
                label: 'Kelola Kategori',
                icon: Icons.sell_outlined,
                route: '/admin/manage-category',
                currentRoute: widget.currentRoute,
                collapsed: _collapsed,
              ),

              const Spacer(),

              // TODO: hubungkan ke logika logout/auth yang sesungguhnya.
              // Untuk sementara diarahkan ke halaman landing.
              _LogoutItem(
                collapsed: _collapsed,
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
            ],
          ),

          // Tombol collapse/expand, ditempel di tepi kanan sidebar supaya
          // sedikit "mengambang" keluar seperti pada versi web.
          Positioned(
            top: 6,
            right: -14,
            child: Material(
              color: AppColors.gold,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => setState(() => _collapsed = !_collapsed),
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  child: Icon(
                    _collapsed ? Icons.chevron_right : Icons.chevron_left,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
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
  final IconData icon;
  final String? route; // null = halaman belum tersedia
  final String currentRoute;
  final bool collapsed;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.currentRoute,
    required this.collapsed,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = route != null && route == currentRoute;
    final bool available = route != null;

    final Widget item = Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? AppColors.gold : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
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
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: collapsed ? 0 : 12,
              ),
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: active ? Colors.black : AppColors.textSecondary,
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        color: active ? Colors.black : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Saat collapsed, bungkus dengan Tooltip supaya label tetap kebaca
    // ketika pointer diarahkan ke ikon.
    return collapsed ? Tooltip(message: label, child: item) : item;
  }
}

class _LogoutItem extends StatelessWidget {
  final VoidCallback onTap;
  final bool collapsed;
  const _LogoutItem({required this.onTap, required this.collapsed});

  @override
  Widget build(BuildContext context) {
    final Widget item = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: collapsed ? 0 : 12,
          ),
          child: Row(
            mainAxisAlignment:
                collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              if (!collapsed) ...const [
                SizedBox(width: 12),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return collapsed ? Tooltip(message: 'Logout', child: item) : item;
  }
}
