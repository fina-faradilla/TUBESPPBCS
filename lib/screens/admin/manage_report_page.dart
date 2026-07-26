import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/laporan_row.dart';
import '../../controllers/laporan_controller.dart';
import '../../utils/status_utils.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/card_container.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/laporan_form_dialog.dart';
import '../../utils/responsive.dart';
import '../../utils/kategori_api.dart';

/// Route: '/admin/manage-report'
class ManageReportPage extends StatefulWidget {
  const ManageReportPage({super.key});

  @override
  State<ManageReportPage> createState() => _ManageReportPageState();
}

class _ManageReportPageState extends State<ManageReportPage> {
  final LaporanController _controller = LaporanController.instance;

  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filterKategori = 'Semua Kategori';
  String _filterStatus = 'Semua Status';

  // Daftar nama kategori untuk filter, diambil dari backend asli (bukan
  // lagi data lokal) supaya konsisten dengan kategori yang benar-benar
  // dipakai laporan.
  List<String> _namaKategoriFilter = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
    _muatKategoriFilter();
    _controller.muatData();
  }

  Future<void> _muatKategoriFilter() async {
    try {
      final data = await KategoriApi.fetchAll();
      if (!mounted) return;
      setState(() => _namaKategoriFilter = data.map((k) => k.nama).toList());
    } catch (_) {
      // Gagal diam-diam — filter kategori cukup tampil "Semua Kategori"
      // saja kalau daftar kategori gagal dimuat; tidak menghalangi
      // halaman lain untuk tetap dipakai.
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  List<LaporanRow> get _filteredRows {
    return _controller.rows.where((r) {
      final matchQuery = _query.isEmpty ||
          r.judul.toLowerCase().contains(_query) ||
          r.pelapor.toLowerCase().contains(_query) ||
          r.id.toLowerCase().contains(_query);
      final matchKategori =
          _filterKategori == 'Semua Kategori' || r.kategori == _filterKategori;
      final matchStatus =
          _filterStatus == 'Semua Status' || r.status == _filterStatus;
      return matchQuery && matchKategori && matchStatus;
    }).toList();
  }

  Future<void> _tambahLaporan() async {
    final result = await showLaporanFormDialog(context);
    if (result == null) return;
    try {
      await _controller.tambahLaporan(
        judul: result.judul,
        pelapor: result.pelapor,
        kategoriId: result.kategoriId,
        status: result.status,
        tingkatKerusakan: result.tingkatKerusakan,
        alamat: result.alamat,
        deskripsi: result.deskripsi,
        lat: result.lat,
        lng: result.lng,
        fotoBytes: result.fotoBytes,
        fotoFileName: result.fotoFileName,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan baru berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan laporan: $e')),
        );
      }
    }
  }

  Future<void> _ubahLaporan(LaporanRow row) async {
    final result = await showLaporanFormDialog(context, existing: row);
    if (result == null) return;
    try {
      await _controller.ubahLaporan(
        row.id,
        judul: result.judul,
        pelapor: result.pelapor,
        kategoriId: result.kategoriId,
        status: result.status,
        tingkatKerusakan: result.tingkatKerusakan,
        alamat: result.alamat,
        deskripsi: result.deskripsi,
        lat: result.lat,
        lng: result.lng,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil diubah')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah laporan: $e')),
        );
      }
    }
  }

  Future<void> _hapusLaporan(LaporanRow row) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text('Hapus Laporan?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Laporan "${row.judul}" (${row.id}) akan dihapus permanen. Lanjutkan?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _controller.hapusLaporan(row.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laporan berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus laporan: $e')),
          );
        }
      }
    }
  }

  void _lihatDetail(LaporanRow row) {
    Navigator.of(context).pushNamed('/admin/detail-laporan', arguments: row.id);
  }

  Future<void> _verifikasiLaporan(LaporanRow row) async {
    try {
      await _controller.verifikasiLaporan(row.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil diverifikasi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal verifikasi laporan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filteredRows;
    final bool mobile = isMobileWidth(context);
    final double pagePad = mobile ? 16 : 28;

    final searchField = Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Cari laporan, lokasi, atau ID...',
                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ),
          if (_searchCtrl.text.isNotEmpty)
            InkWell(
              onTap: () => _searchCtrl.clear(),
              child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
            ),
        ],
      ),
    );

    final kategoriDropdown = _FilterDropdown(
      value: _filterKategori,
      options: ['Semua Kategori', ..._namaKategoriFilter],
      onChanged: (v) => setState(() => _filterKategori = v),
    );
    final statusDropdown = _FilterDropdown(
      value: _filterStatus,
      options: const ['Semua Status', ...kStatusOptions],
      onChanged: (v) => setState(() => _filterStatus = v),
    );

    // Di laptop: search + 2 dropdown sejajar dalam satu baris.
    // Di HP: search full-width di atas, dua dropdown di bawahnya
    // supaya tidak berdesakan di layar sempit.
    final Widget filterBar = mobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchField,
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: kategoriDropdown),
                  const SizedBox(width: 12),
                  Expanded(child: statusDropdown),
                ],
              ),
            ],
          )
        : Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 12),
              kategoriDropdown,
              const SizedBox(width: 12),
              statusDropdown,
            ],
          );

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TopBar(
          breadcrumb: 'PORTAL ADMIN / DINAS',
          title: 'KELOLA LAPORAN',
          trailing: ElevatedButton.icon(
            onPressed: _tambahLaporan,
            icon: const Icon(Icons.add, size: 16, color: Colors.black),
            label: Text(mobile ? 'Tambah' : 'Tambah Manual',
                style: const TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(pagePad, 8, pagePad, 28),
            child: CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  filterBar,
                  const SizedBox(height: 20),

                  if (!mobile) ...[
                    const _TableHeaderRow(),
                    const Divider(color: AppColors.cardBorder, height: 24),
                  ],

                  // Baris data
                  if (_controller.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (_controller.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'Gagal memuat laporan: ${_controller.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => _controller.muatData(force: true),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (rows.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Tidak ada laporan yang cocok dengan pencarian/filter.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    for (int i = 0; i < rows.length; i++) ...[
                      mobile
                          ? _ReportCard(
                              row: rows[i],
                              onDetail: () => _lihatDetail(rows[i]),
                              onEdit: () => _ubahLaporan(rows[i]),
                              onVerifikasi: () => _verifikasiLaporan(rows[i]),
                              onHapus: () => _hapusLaporan(rows[i]),
                            )
                          : _TableDataRow(
                              row: rows[i],
                              onDetail: () => _lihatDetail(rows[i]),
                              onEdit: () => _ubahLaporan(rows[i]),
                              onVerifikasi: () => _verifikasiLaporan(rows[i]),
                              onHapus: () => _hapusLaporan(rows[i]),
                            ),
                      if (i != rows.length - 1)
                        mobile
                            ? const SizedBox(height: 12)
                            : const Divider(color: AppColors.cardBorder, height: 32),
                    ],

                  const SizedBox(height: 20),
                  Text(
                    'Menampilkan ${rows.length} dari ${_controller.total} laporan',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (mobile) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.sidebarBg,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: const Text('RoadFix',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        ),
        drawer: const Drawer(
          backgroundColor: Colors.transparent,
          child: Sidebar(currentRoute: '/admin/manage-report'),
        ),
        body: content,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const Sidebar(currentRoute: '/admin/manage-report'),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.cardBg,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textSecondary),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  static const TextStyle style = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 2, child: Text('ID', style: style)),
        Expanded(flex: 3, child: Text('JUDUL', style: style)),
        Expanded(flex: 3, child: Text('PELAPOR', style: style)),
        Expanded(flex: 2, child: Text('KATEGORI', style: style)),
        Expanded(flex: 3, child: Text('DESKRIPSI', style: style)),
        Expanded(flex: 3, child: Text('STATUS', style: style)),
        Expanded(flex: 2, child: Text('TANGGAL', style: style)),
        Expanded(flex: 3, child: Text('AKSI', style: style)),
      ],
    );
  }
}

class _AksiIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  const _AksiIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              icon,
              size: 18,
              color: enabled ? color : color.withOpacity(0.35),
            ),
          ),
        ),
      ),
    );
  }
}

class _TableDataRow extends StatelessWidget {
  final LaporanRow row;
  final VoidCallback onDetail;
  final VoidCallback onEdit;
  final VoidCallback onVerifikasi;
  final VoidCallback onHapus;

  const _TableDataRow({
    required this.row,
    required this.onDetail,
    required this.onEdit,
    required this.onVerifikasi,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: AppColors.textPrimary, fontSize: 13);
    final bool sudahSelesai = row.status == 'Selesai';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(row.id, style: textStyle)),
        Expanded(flex: 3, child: Text(row.judul, style: textStyle)),
        Expanded(flex: 3, child: Text(row.pelapor, style: textStyle)),
        Expanded(flex: 2, child: Text(row.kategori, style: textStyle)),
        Expanded(
          flex: 3,
          child: Text(
            row.deskripsi,
            style: textStyle.copyWith(color: AppColors.textSecondary, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(flex: 3, child: StatusBadge(label: row.status, color: row.statusColor)),
        Expanded(flex: 2, child: Text(row.tanggal, style: textStyle)),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              _AksiIcon(
                icon: Icons.visibility_outlined,
                color: AppColors.textSecondary,
                tooltip: 'Detail',
                onTap: onDetail,
              ),
              const SizedBox(width: 8),
              _AksiIcon(
                icon: Icons.edit_outlined,
                color: AppColors.gold,
                tooltip: 'Ubah',
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _AksiIcon(
                icon: Icons.check_circle_outline,
                color: AppColors.blue,
                tooltip: 'Verifikasi',
                onTap: sudahSelesai ? null : onVerifikasi,
              ),
              const SizedBox(width: 8),
              _AksiIcon(
                icon: Icons.delete_outline,
                color: Colors.redAccent,
                tooltip: 'Hapus',
                onTap: onHapus,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Versi kartu dari satu baris laporan, dipakai saat layar sempit (HP)
/// supaya tidak perlu memampatkan 8 kolom tabel ke lebar yang tidak cukup.
class _ReportCard extends StatelessWidget {
  final LaporanRow row;
  final VoidCallback onDetail;
  final VoidCallback onEdit;
  final VoidCallback onVerifikasi;
  final VoidCallback onHapus;

  const _ReportCard({
    required this.row,
    required this.onDetail,
    required this.onEdit,
    required this.onVerifikasi,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final bool sudahSelesai = row.status == 'Selesai';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
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
                    Text(row.id,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(row.judul,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              StatusBadge(label: row.status, color: row.statusColor),
            ],
          ),
          const SizedBox(height: 10),
          _CardInfoLine(label: 'Pelapor', value: row.pelapor),
          _CardInfoLine(label: 'Kategori', value: row.kategori),
          _CardInfoLine(label: 'Tanggal', value: row.tanggal),
          const SizedBox(height: 4),
          Text(
            row.deskripsi,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _AksiIcon(
                icon: Icons.visibility_outlined,
                color: AppColors.textSecondary,
                tooltip: 'Detail',
                onTap: onDetail,
              ),
              const SizedBox(width: 8),
              _AksiIcon(
                icon: Icons.edit_outlined,
                color: AppColors.gold,
                tooltip: 'Ubah',
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _AksiIcon(
                icon: Icons.check_circle_outline,
                color: AppColors.blue,
                tooltip: 'Verifikasi',
                onTap: sudahSelesai ? null : onVerifikasi,
              ),
              const SizedBox(width: 8),
              _AksiIcon(
                icon: Icons.delete_outline,
                color: Colors.redAccent,
                tooltip: 'Hapus',
                onTap: onHapus,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardInfoLine extends StatelessWidget {
  final String label;
  final String value;
  const _CardInfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
