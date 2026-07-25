import 'package:flutter/material.dart';

import '../../models/kategori_option.dart';
import '../../models/laporan_row.dart';
import '../../theme/app_colors.dart';
import '../../controllers/laporan_controller.dart';
import '../../utils/kategori_api.dart';
import '../../utils/status_utils.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/card_container.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/laporan_form_dialog.dart';

// ============================================================
//  ManageReportPage — Route: '/admin/manage-report'
// ============================================================

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

  // Kategori dari API
  List<KategoriOption> _kategoriOptions = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.muatData();
      _muatKategori();
    });
    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Future<void> _muatKategori() async {
    try {
      final data = await KategoriApi.fetchAll();
      if (!mounted) return;
      setState(() {
        _kategoriOptions = data;
      });
    } catch (e) {
      // Kategori gagal dimuat — filter akan kosong, bukan error kritis
    }
  }

  List<LaporanRow> get _filteredRows {
    return _controller.rows.where((r) {
      final matchQuery =
          _query.isEmpty ||
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
    if (result == null || !mounted) return;

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
        fotoBytes: result.fotoBytes?.toList(),
        fotoFileName: result.fotoFileName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil ditambahkan')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  Future<void> _verifikasiLaporan(String id) async {
    try {
      await _controller.verifikasiLaporan(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil diverifikasi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal verifikasi: $e')));
    }
  }

  Future<void> _hapusLaporan(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text(
          'Hapus Laporan',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Yakin ingin menghapus laporan ini?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _controller.hapusLaporan(id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Laporan berhasil dihapus')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }

  void _bukaDetail(String id) {
    Navigator.of(context).pushNamed('/admin/detail-laporan', arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(currentRoute: '/admin/manage-report'),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBar(
                  breadcrumb: 'PORTAL ADMIN / DINAS',
                  title: 'KELOLA LAPORAN',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _tambahLaporan,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Tambah Laporan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Search & Filter
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
                  child: Row(
                    children: [
                      // Search box
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Cari laporan...',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.search,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Filter Kategori
                      _filterDropdown(
                        value: _filterKategori,
                        items: [
                          'Semua Kategori',
                          ..._kategoriOptions.map((k) => k.nama),
                        ],
                        onChanged: (v) => setState(() => _filterKategori = v!),
                      ),
                      const SizedBox(width: 12),
                      // Filter Status
                      _filterDropdown(
                        value: _filterStatus,
                        items: ['Semua Status', ...kStatusOptions],
                        onChanged: (v) => setState(() => _filterStatus = v!),
                      ),
                    ],
                  ),
                ),
                // Tabel laporan
                Expanded(
                  child: _controller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                          ),
                        )
                      : _controller.error != null
                      ? Center(
                          child: Text(
                            'Gagal memuat data: ${_controller.error}',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : _filteredRows.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada laporan.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                          children: [
                            CardContainer(
                              child: Column(
                                children: [
                                  // Header tabel
                                  Container(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        _headerCell('ID', flex: 1),
                                        _headerCell('Judul', flex: 3),
                                        _headerCell('Pelapor', flex: 2),
                                        _headerCell('Kategori', flex: 2),
                                        _headerCell('Status', flex: 2),
                                        _headerCell('Aksi', flex: 2),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    color: AppColors.cardBorder,
                                    height: 1,
                                  ),
                                  // Data rows
                                  ..._filteredRows.map((row) => _buildRow(row)),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRow(LaporanRow row) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              row.id.length > 8
                  ? '...${row.id.substring(row.id.length - 8)}'
                  : row.id,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.judul,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.pelapor,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.kategori,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: StatusBadge(label: row.status, color: row.statusColor),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _actionBtn(
                  icon: Icons.visibility,
                  tooltip: 'Detail',
                  onTap: () => _bukaDetail(row.id),
                ),
                if (row.status == 'Menunggu')
                  _actionBtn(
                    icon: Icons.check_circle_outline,
                    tooltip: 'Verifikasi',
                    color: AppColors.green,
                    onTap: () => _verifikasiLaporan(row.id),
                  ),
                _actionBtn(
                  icon: Icons.delete_outline,
                  tooltip: 'Hapus',
                  color: Colors.redAccent,
                  onTap: () => _hapusLaporan(row.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = AppColors.textSecondary,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }

  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: false,
          dropdownColor: AppColors.cardBg,
          iconEnabledColor: AppColors.textSecondary,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
          items: items
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
