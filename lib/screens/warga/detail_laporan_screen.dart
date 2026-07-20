import 'package:flutter/material.dart';
import '../../models/laporan_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/sidebar_menu.dart';

/// Halaman "Detail Laporan" — info lengkap satu laporan beserta
/// timeline riwayat tindak lanjut dari admin/dinas.
class DetailLaporanScreen extends StatelessWidget {
  final Laporan laporan;

  const DetailLaporanScreen({super.key, required this.laporan});

  String _formatTanggal(DateTime d) {
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${bulan[d.month]} ${d.year}';
  }

  String _formatWaktu(DateTime d) {
    return '${_formatTanggal(d)}, '
        '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Row(
        children: [
          SidebarMenu(
            activeItem: 'Detail Laporan',
            items: [
              SidebarMenuItem(
                label: 'Buat Laporan',
                icon: Icons.add_circle_outline,
                onTap: () => Navigator.of(context).pushReplacementNamed(
                  '/warga/buat-laporan',
                ),
              ),
              SidebarMenuItem(
                label: 'Riwayat Laporan Saya',
                icon: Icons.history,
                onTap: () => Navigator.of(context).pushReplacementNamed(
                  '/warga/riwayat-laporan',
                ),
              ),
              SidebarMenuItem(
                label: 'Detail Laporan',
                icon: Icons.description_outlined,
                onTap: () {},
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LAPORAN #${laporan.id}',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    laporan.judul.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${laporan.lokasi} · Dilaporkan '
                    '${_formatTanggal(laporan.tanggal)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 760;
                      final infoColumn = _buildInfoColumn();
                      final timelineColumn = _buildTimelineColumn();
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: infoColumn),
                            const SizedBox(width: 24),
                            Expanded(flex: 2, child: timelineColumn),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          infoColumn,
                          const SizedBox(height: 24),
                          timelineColumn,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: laporan.fotoUrl != null
                // TODO: tampilkan Image.network(laporan.fotoUrl!) jika ada.
                ? const Icon(Icons.image, color: AppColors.textSecondary)
                : const Text(
                    'Foto bukti kerusakan',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _labelValue('Kategori', laporan.kategori),
              ),
              Expanded(
                child: _labelValue(
                  'Tingkat',
                  null,
                  badge: _TingkatBadge(tingkat: laporan.tingkat),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _labelValue('Deskripsi', laporan.deskripsi),
        ],
      ),
    );
  }

  Widget _labelValue(String label, String? value, {Widget? badge}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        badge ??
            Text(
              value ?? '-',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
      ],
    );
  }

  Widget _buildTimelineColumn() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RIWAYAT TINDAK LANJUT',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 18),
          for (int i = 0; i < laporan.riwayat.length; i++)
            _TimelineEntry(
              entry: laporan.riwayat[i],
              isLast: i == laporan.riwayat.length - 1,
              formatWaktu: _formatWaktu,
            ),
          if (laporan.riwayat.isEmpty)
            const Text(
              'Belum ada tindak lanjut.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final RiwayatTindakLanjut entry;
  final bool isLast;
  final String Function(DateTime) formatWaktu;

  const _TimelineEntry({
    required this.entry,
    required this.isLast,
    required this.formatWaktu,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: AppColors.cardBorder,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatWaktu(entry.waktu),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.judul,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.keterangan,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}

class _TingkatBadge extends StatelessWidget {
  final String tingkat;
  const _TingkatBadge({required this.tingkat});

  Color get _color => AppColors.tingkatColor(tingkat);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            tingkat.toUpperCase(),
            style: TextStyle(
              color: _color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}