import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SidebarMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const SidebarMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

/// Sidebar navigasi khusus Portal Warga (RoadFix).
/// Hanya menampilkan menu Portal Warga — tidak ada menu publik/admin.
/// Dipakai di setiap screen pada folder `warga/` supaya konsisten.
class SidebarMenu extends StatelessWidget {
  final String activeItem;
  final List<SidebarMenuItem> items;

  /// Kalau diisi, tombol "Keluar" otomatis muncul di bagian bawah sidebar
  /// — cukup pasang sekali di sini, tidak perlu ditambahkan manual di
  /// setiap screen yang pakai SidebarMenu.
  final VoidCallback? onLogout;

  const SidebarMenu({
    super.key,
    required this.activeItem,
    required this.items,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      color: AppColors.sidebarBg,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBrand(),
          const SizedBox(height: 28),
          _sectionLabel('PORTAL WARGA'),
          for (final item in items)
            _item(item.label, item.icon, item.onTap, activeItem == item.label),
          if (onLogout != null) ...[
             const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: AppColors.cardBorder, height: 1),
            ),
            const SizedBox(height: 8),
            _logoutItem(onLogout!),
          ],
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'RF',
              style: TextStyle(
                color: AppColors.onGold,
                fontWeight: FontWeight.bold,
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
                  'LAPOR JALAN RUSAK',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _item(String label, IconData icon, VoidCallback onTap, bool active) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? AppColors.onGold : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.onGold : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoutItem(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: const Row(
          children: [
            Icon(Icons.logout, size: 16, color: Colors.redAccent),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
