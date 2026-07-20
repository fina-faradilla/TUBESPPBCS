import 'package:flutter/material.dart';
import '../../models/laporan_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/sidebar_menu.dart';

/// Halaman "Riwayat Laporan Saya" — daftar seluruh laporan yang
/// pernah diajukan warga beserta status terkininya.
class RiwayatLaporanScreen extends StatefulWidget {
  const RiwayatLaporanScreen({super.key});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen> {
  final _searchController = TextEditingController();
  String _statusFilter = 'Semua Status';
  int _currentPage = 1;

  final List<String> _statusOptions = const [
    'Semua Status',
    'BARU',
    'DIPROSES',
    'SELESAI',
    'DITOLAK',
  ];

  // TODO: ganti dengan data dari API / provider.
  final List<Laporan> _laporanList = [
    Laporan(
      id: 'RF-2026-0143',
      judul: 'Jalan Berlubang Besar',
      lokasi: 'Jl. Merdeka No. 12',
      deskripsi: '',
      kategori: 'Jalan Berlubang',
      tingkat: 'Berat',
      status: 'BARU',
      tanggal: DateTime(2026, 7, 3),
    ),
    Laporan(
      id: 'RF-2026-0139',
      judul: 'Aspal Retak Parah',
      lokasi: 'Jl. Sudirman KM 3',
      deskripsi: '',
      kategori: 'Aspal Retak',
      tingkat: 'Sedang',
      status: 'DIPROSES',
      tanggal: DateTime(2026, 6, 29),
    ),
    Laporan(
      id: 'RF-2026-0121',
      judul: 'Jalan Ambles Sebagian',
      lokasi: 'Jl. Anggrek Raya',
      deskripsi: '',
      kategori: 'Jalan Ambles',
      tingkat: 'Berat',
      status: 'SELESAI',
      tanggal: DateTime(2026, 6, 18),
    ),
    Laporan(
      id: 'RF-2026-0108',
      judul: 'Lubang Kecil Menyebar',
      lokasi: 'Jl. Kenanga No. 5',
      deskripsi: '',
      kategori: 'Jalan Berlubang',
      tingkat: 'Ringan',
      status: 'DITOLAK',
      tanggal: DateTime(2026, 6, 10),
    ),
  ];

  List<Laporan> get _filteredList {
    final query = _searchController.text.trim().toLowerCase();
    return _laporanList.where((l) {
      final matchesQuery = query.isEmpty ||
          l.judul.toLowerCase().contains(query) ||
          l.lokasi.toLowerCase().contains(query);
      final matchesStatus =
          _statusFilter == 'Semua Status' || l.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  }

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Row(
        children: [
          SidebarMenu(
            activeItem: 'Riwayat Laporan Saya',
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
                onTap: () {},
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
                  const Text(
                    'PORTAL WARGA',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'RIWAYAT LAPORAN SAYA',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pantau status seluruh laporan yang pernah Anda ajukan.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildToolbar(),
                        const SizedBox(height: 16),
                        _buildTableHeader(),
                        const Divider(color: AppColors.cardBorder, height: 1),
                        for (final laporan in _filteredList)
                          _buildTableRow(laporan),
                        const SizedBox(height: 16),
                        _buildPagination(),
                      ],
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

  Widget _buildToolbar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 560;
        final search = TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search,
                color: AppColors.textSecondary, size: 18),
            hintText: 'Cari judul atau lokasi laporan...',
          ),
        );
        final dropdown = DropdownButtonFormField<String>(
          value: _statusFilter,
          dropdownColor: AppColors.bgDark,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          items: _statusOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) =>
              setState(() => _statusFilter = v ?? _statusFilter),
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(flex: 3, child: search),
              const SizedBox(width: 16),
              SizedBox(width: 180, child: dropdown),
            ],
          );
        }
        return Column(
          children: [
            search,
            const SizedBox(height: 12),
            dropdown,
          ],
        );
      },
    );
  }

  Widget _buildTableHeader() {
    const style = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('JUDUL LAPORAN', style: style)),
          Expanded(flex: 2, child: Text('LOKASI', style: style)),
          Expanded(flex: 2, child: Text('TANGGAL', style: style)),
          Expanded(flex: 2, child: Text('STATUS', style: style)),
          Expanded(flex: 1, child: Text('')),
        ],
      ),
    );
  }

  Widget _buildTableRow(Laporan laporan) {
    return InkWell(
      onTap: () {
        // TODO: navigasi ke DetailLaporanScreen dengan laporan.id
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                laporan.judul,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                laporan.lokasi,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _formatTanggal(laporan.tanggal),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: _StatusBadge(status: laporan.status),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  const Text(
                    'Lihat',
                    style: TextStyle(color: AppColors.gold, fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward,
                      color: AppColors.gold, size: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: _currentPage > 1
              ? () => setState(() => _currentPage--)
              : null,
          icon: const Icon(Icons.chevron_left,
              color: AppColors.textSecondary, size: 18),
        ),
        for (final page in [1, 2, 3])
          _buildPageChip(page),
        IconButton(
          onPressed: _currentPage < 3
              ? () => setState(() => _currentPage++)
              : null,
          icon: const Icon(Icons.chevron_right,
              color: AppColors.textSecondary, size: 18),
        ),
      ],
    );
  }

  Widget _buildPageChip(int page) {
    final active = page == _currentPage;
    return GestureDetector(
      onTap: () => setState(() => _currentPage = page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.gold : AppColors.bgDark,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            color: active ? AppColors.onGold : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}