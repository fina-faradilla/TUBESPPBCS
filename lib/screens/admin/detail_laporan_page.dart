import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_colors.dart';
import '../../controllers/laporan_controller.dart';
import '../../models/tindak_lanjut.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/card_container.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tindak_lanjut_form_dialog.dart';

/// Route: '/admin/detail-laporan'
/// Menerima argumen berupa String [id] laporan lewat
/// `Navigator.pushNamed(context, '/admin/detail-laporan', arguments: id)`.
class DetailLaporanPage extends StatefulWidget {
  const DetailLaporanPage({super.key});

  @override
  State<DetailLaporanPage> createState() => _DetailLaporanPageState();
}

class _DetailLaporanPageState extends State<DetailLaporanPage> {
  int _tab = 0; // 0 = Detail Laporan, 1 = Riwayat Tindak Lanjut

  @override
  Widget build(BuildContext context) {
    // Diakses lewat argumen (Navigator.pushNamed(..., arguments: id)).
    // Bisa jadi null kalau halaman ini dibuka langsung lewat URL atau
    // di-refresh di browser, karena Flutter Web membangun ulang route
    // hanya dari URL tanpa membawa `arguments`. Maka itu di-cast secara
    // aman (bukan `as String`) supaya tidak crash.
    final args = ModalRoute.of(context)?.settings.arguments;
    final id = args is String ? args : null;
    final controller = LaporanController.instance;

    return Scaffold(
      body: Row(
        children: [
          const Sidebar(currentRoute: '/admin/manage-report'),
          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final row = id == null ? null : controller.getById(id);

                if (row == null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TopBar(
                        breadcrumb: 'PORTAL ADMIN / DINAS',
                        title: 'DETAIL LAPORAN',
                        trailing: TextButton.icon(
                          onPressed: () => Navigator.of(context)
                              .pushReplacementNamed('/admin/manage-report'),
                          icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.textSecondary),
                          label: const Text('Kembali ke Kelola Laporan',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Laporan tidak ditemukan.\nSilakan buka halaman ini lewat tombol Detail pada Kelola Laporan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopBar(
                      breadcrumb: 'PORTAL ADMIN / DINAS',
                      title: 'DETAIL LAPORAN',
                      trailing: TextButton.icon(
                        onPressed: () => Navigator.of(context)
                            .pushReplacementNamed('/admin/manage-report'),
                        icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.textSecondary),
                        label: const Text('Kembali ke Kelola Laporan',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                    // ===== Tab: Detail Laporan / Riwayat Tindak Lanjut =====
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                      child: Row(
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
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(28, 8, 28, 0),
                      child: Divider(color: AppColors.cardBorder, height: 1),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
                        child: _tab == 0
                            ? _DetailTab(row: row)
                            : _RiwayatTab(
                                laporanId: row.id,
                                tindakLanjuts: row.tindakLanjuts,
                                controller: controller,
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
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

/// Isi tab "Detail Laporan": info utama, deskripsi, foto, dan peta.
class _DetailTab extends StatelessWidget {
  final dynamic row; // LaporanRow, dynamic supaya file ini ringkas dari import

  const _DetailTab({required this.row});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kolom kiri: info utama + deskripsi + peta
          Expanded(
            flex: 3,
            child: Column(
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
                                  row.id,
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
                          Expanded(child: _InfoField(label: 'PELAPOR', value: row.pelapor)),
                          Expanded(child: _InfoField(label: 'KATEGORI', value: row.kategori)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _InfoField(
                                  label: 'TINGKAT KERUSAKAN', value: row.tingkatKerusakan)),
                          Expanded(child: _InfoField(label: 'TANGGAL LAPOR', value: row.tanggal)),
                        ],
                      ),
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
                        row.deskripsi,
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
                                height: 320,
                                child: _PetaLaporan(
                                  judul: row.judul,
                                  lat: row.lat,
                                  lng: row.lng,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Kolom kanan: foto kerusakan
          Expanded(
            flex: 2,
            child: CardContainer(
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
                  Expanded(
                    child: Container(
                      width: double.infinity,
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
                              child: Image.network(row.fotoPath!, fit: BoxFit.cover),
                            ),
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

/// Isi tab "Riwayat Tindak Lanjut": linimasa penanganan laporan.
class _RiwayatTab extends StatelessWidget {
  final String laporanId;
  final List<TindakLanjut> tindakLanjuts;
  final LaporanController controller;

  const _RiwayatTab({
    required this.laporanId,
    required this.tindakLanjuts,
    required this.controller,
  });

  static const List<String> _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatTanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  Future<void> _tambah(BuildContext context) async {
    final result = await showTindakLanjutFormDialog(context);
    if (result == null) return;
    controller.tambahTindakLanjut(
      laporanId,
      judul: result.judul,
      keterangan: result.keterangan,
    );
  }

  Widget _tombolTambah(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _tambah(context),
      icon: const Icon(Icons.add, size: 18, color: Colors.black),
      label: const Text('Tambah Tindak Lanjut',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tindakLanjuts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _tombolTambah(context),
          ),
          const SizedBox(height: 16),
          CardContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada riwayat tindak lanjut untuk laporan ini.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _tombolTambah(context),
        ),
        const SizedBox(height: 16),
        CardContainer(
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
                      Text(t.judul,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(t.keterangan,
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
        ),
      ],
    );
  }
}

/// Peta OpenStreetMap interaktif (pengganti Leaflet.js di versi web),
/// menampilkan marker + label judul laporan pada titik koordinatnya.
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
          userAgentPackageName: 'com.roadfix.admin',
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
          value,
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