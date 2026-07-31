import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/warga_laporan_controller.dart';
import '../../models/laporan_row.dart';
import '../../theme/app_colors.dart';
import '../../utils/auth_storage.dart';
import '../../utils/responsive.dart';
import '../../widgets/card_container.dart';
import '../../widgets/sidebar_menu.dart';
import '../../widgets/status_badge.dart';

/// Halaman "Detail Laporan" milik warga — versi lengkap yang setara
/// dengan halaman detail di Portal Admin (info lengkap, foto, peta,
/// dan riwayat tindak lanjut), tapi READ-ONLY: warga hanya bisa melihat,
/// tidak bisa mengubah status atau menambah tindak lanjut sendiri.
///
/// Route: '/warga/detail-laporan'
/// Argumen: String [id] laporan, dikirim lewat
/// `Navigator.pushNamed(context, '/warga/detail-laporan', arguments: id)`.
class DetailLaporanScreen extends StatefulWidget {
  const DetailLaporanScreen({super.key});

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  final _controller = WargaLaporanController.instance;
  int _tab = 0; // 0 = Detail Laporan, 1 = Riwayat Tindak Lanjut

  String? _id;
  bool _loadingDetail = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Argumen hanya bisa dibaca lewat ModalRoute, jadi diambil di sini
    // (bukan initState) dan cuma dijalankan sekali per halaman.
    if (_id == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      _id = args is String ? args : null;
      _controller.addListener(_onChanged);
      _muatDetail();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Future<void> _muatDetail() async {
    if (_id == null) {
      setState(() => _loadingDetail = false);
      return;
    }
    setState(() => _loadingDetail = true);
    await _controller.muatDetail(_id!);
    if (!mounted) return;
    setState(() => _loadingDetail = false);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text(
          'Keluar dari akun?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await AuthStorage.clearToken();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _kembali() {
    Navigator.of(context).pushReplacementNamed('/warga/riwayat-laporan');
  }

  @override
  Widget build(BuildContext context) {
    final row = _id == null ? null : _controller.getById(_id!);
    final bool mobile = isMobileWidth(context);

    final sidebarItems = [
      SidebarMenuItem(
        label: 'Buat Laporan',
        icon: Icons.add_circle_outline,
        onTap: () => Navigator.of(
          context,
        ).pushReplacementNamed('/warga/buat-laporan'),
      ),
      SidebarMenuItem(
        label: 'Riwayat Laporan Saya',
        icon: Icons.history,
        onTap: _kembali,
      ),
    ];

    final Widget content = _loadingDetail && row == null
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          )
        : row == null
            ? _buildNotFound()
            : _buildDetail(row, mobile);

    if (mobile) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.sidebarBg,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: const Text('RoadFix',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        ),
        drawer: Drawer(
          backgroundColor: Colors.transparent,
          child: SidebarMenu(
            activeItem: 'Riwayat Laporan Saya',
            onLogout: _logout,
            items: sidebarItems,
          ),
        ),
        body: content,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SidebarMenu(
            activeItem: 'Riwayat Laporan Saya',
            onLogout: _logout,
            items: sidebarItems,
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(title: 'DETAIL LAPORAN'),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              'Laporan tidak ditemukan.\nSilakan buka halaman ini lewat '
              'Riwayat Laporan Saya.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({required String title, String? subtitle}) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.start,
      runSpacing: 8,
      children: [
        Column(
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
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
        TextButton.icon(
          onPressed: _kembali,
          icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.textSecondary),
          label: const Text(
            'Kembali ke Riwayat',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildDetail(LaporanRow row, bool mobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(mobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            title: row.judul.toUpperCase(),
            subtitle: '${row.alamat} · Dilaporkan ${row.tanggal}',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _TabButton(
                label: 'Detail Laporan',
                selected: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
              const SizedBox(width: 20),
              _TabButton(
                label: 'Riwayat Tindak Lanjut',
                selected: _tab == 1,
                badgeCount: row.tindakLanjuts.length,
                onTap: () => setState(() => _tab = 1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 20),
          _tab == 0 ? _DetailTab(row: row) : _RiwayatTab(row: row),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.gold : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.gold : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                      color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Isi tab "Detail Laporan": info utama, deskripsi, foto, dan peta lokasi.
class _DetailTab extends StatelessWidget {
  final LaporanRow row;
  const _DetailTab({required this.row});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 760;
        final infoColumn = _buildInfoColumn();
        final fotoColumn = _buildFotoColumn();
        if (isWide) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: infoColumn),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: fotoColumn),
              ],
            ),
          );
        }
        return Column(
          children: [
            infoColumn,
            const SizedBox(height: 16),
            fotoColumn,
          ],
        );
      },
    );
  }

  Widget _buildInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${row.id}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          row.judul,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(label: row.status, color: row.statusColor),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _InfoField(label: 'KATEGORI', value: row.kategori)),
                  Expanded(
                    child: _InfoField(
                      label: 'TINGKAT KERUSAKAN',
                      value: row.tingkatKerusakan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _InfoField(label: 'TANGGAL LAPOR', value: row.tanggal),
              const SizedBox(height: 20),
              _InfoField(label: 'ALAMAT', value: row.alamat),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DESKRIPSI',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                row.deskripsi.isEmpty ? '-' : row.deskripsi,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LOKASI DI PETA',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              (row.lat == null || row.lng == null)
                  ? Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.bgDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Belum ada titik lokasi untuk laporan ini.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 260,
                        child: _PetaLaporan(
                          judul: row.judul,
                          lat: row.lat!,
                          lng: row.lng!,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFotoColumn() {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FOTO KERUSAKAN',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            alignment: Alignment.center,
            child: row.fotoPath == null
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Belum ada foto untuk laporan ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(row.fotoPath!, fit: BoxFit.cover, width: double.infinity),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Isi tab "Riwayat Tindak Lanjut": linimasa penanganan laporan.
/// READ-ONLY untuk warga — tidak ada tombol tambah/ubah seperti di admin.
class _RiwayatTab extends StatelessWidget {
  final LaporanRow row;
  const _RiwayatTab({required this.row});

  static const List<String> _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatTanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final tindakLanjuts = row.tindakLanjuts;

    if (tindakLanjuts.isEmpty) {
      return CardContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'Belum ada tindak lanjut dari petugas untuk laporan ini.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ),
      );
    }

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(tindakLanjuts.length, (i) {
          final t = tindakLanjuts[i];
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: i == tindakLanjuts.length - 1
                  ? null
                  : const Border(bottom: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 5, right: 12),
                  decoration:
                      const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (t.status == 'Selesai'
                                      ? Colors.green
                                      : Colors.blue)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              t.status,
                              style: TextStyle(
                                color: t.status == 'Selesai'
                                    ? Colors.green
                                    : Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(t.catatan,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                      const SizedBox(height: 4),
                      Text(
                        _formatTanggal(t.createdAt),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Peta OpenStreetMap read-only menampilkan titik lokasi laporan.
class _PetaLaporan extends StatelessWidget {
  final String judul;
  final double lat;
  final double lng;

  const _PetaLaporan({required this.judul, required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(lat, lng);
    return FlutterMap(
      options: MapOptions(
        initialCenter: point,
        initialZoom: 16,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.roadfix.warga',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 160,
              height: 70,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Text(
                      judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.location_on, color: Colors.redAccent, size: 32),
                ],
              ),
            ),
          ],
        ),
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
        ),
      ],
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
