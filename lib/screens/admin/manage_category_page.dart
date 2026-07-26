import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/kategori_option.dart';
import '../../utils/kategori_api.dart';
import '../../utils/responsive.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/card_container.dart';
import '../../widgets/kategori_form_dialog.dart';

/// Route: '/admin/manage-category'
class ManageCategoryPage extends StatefulWidget {
  const ManageCategoryPage({super.key});

  @override
  State<ManageCategoryPage> createState() => _ManageCategoryPageState();
}

class _ManageCategoryPageState extends State<ManageCategoryPage> {
  List<KategoriOption> _rows = [];
  bool _loading = true;
  String? _error;

  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
    _muatData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await KategoriApi.fetchAll();
      if (!mounted) return;
      setState(() {
        _rows = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<KategoriOption> get _filteredRows {
    return _rows.where((k) {
      return _query.isEmpty ||
          k.nama.toLowerCase().contains(_query) ||
          k.id.toString().contains(_query);
    }).toList();
  }

  Future<void> _tambahKategori() async {
    final result = await showKategoriFormDialog(context);
    if (result == null) return;
    try {
      await KategoriApi.create(nama: result.nama, deskripsi: result.deskripsi);
      await _muatData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori baru berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan kategori: $e')),
        );
      }
    }
  }

  Future<void> _ubahKategori(KategoriOption row) async {
    final result = await showKategoriFormDialog(context, existing: row);
    if (result == null) return;
    try {
      await KategoriApi.update(row.id, nama: result.nama, deskripsi: result.deskripsi);
      await _muatData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil diubah')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah kategori: $e')),
        );
      }
    }
  }

  Future<void> _hapusKategori(KategoriOption row) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text('Hapus Kategori?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Kategori "${row.nama}" akan dihapus permanen. Lanjutkan?',
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
    if (confirm != true) return;

    try {
      await KategoriApi.delete(row.id);
      await _muatData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus kategori: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filteredRows;
    final bool mobile = isMobileWidth(context);
    final double pagePad = mobile ? 16 : 28;

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TopBar(
          breadcrumb: 'PORTAL ADMIN / DINAS',
          title: 'KELOLA KATEGORI',
          trailing: ElevatedButton.icon(
            onPressed: _tambahKategori,
            icon: const Icon(Icons.add, size: 16, color: Colors.black),
            label: Text(mobile ? 'Tambah' : 'Tambah Kategori',
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
                  // Search bar
                  Container(
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
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 13),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Cari kategori atau ID...',
                              hintStyle: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ),
                        if (_searchCtrl.text.isNotEmpty)
                          InkWell(
                            onTap: () => _searchCtrl.clear(),
                            child: const Icon(Icons.close,
                                size: 16, color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (!mobile) ...[
                    const _TableHeaderRow(),
                    const Divider(color: AppColors.cardBorder, height: 24),
                  ],

                  // Baris data
                  if (_loading)
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
                  else if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'Gagal memuat kategori: $_error',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _muatData,
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
                          'Tidak ada kategori yang cocok dengan pencarian.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    for (int i = 0; i < rows.length; i++) ...[
                      mobile
                          ? _CategoryCard(
                              row: rows[i],
                              onEdit: () => _ubahKategori(rows[i]),
                              onHapus: () => _hapusKategori(rows[i]),
                            )
                          : _TableDataRow(
                              row: rows[i],
                              onEdit: () => _ubahKategori(rows[i]),
                              onHapus: () => _hapusKategori(rows[i]),
                            ),
                      if (i != rows.length - 1)
                        mobile
                            ? const SizedBox(height: 12)
                            : const Divider(color: AppColors.cardBorder, height: 32),
                    ],

                  const SizedBox(height: 20),
                  Text(
                    'Menampilkan ${rows.length} dari ${_rows.length} kategori',
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
          child: Sidebar(currentRoute: '/admin/manage-category'),
        ),
        body: content,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const Sidebar(currentRoute: '/admin/manage-category'),
          Expanded(child: content),
        ],
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
        Expanded(flex: 3, child: Text('NAMA KATEGORI', style: style)),
        Expanded(flex: 5, child: Text('DESKRIPSI', style: style)),
        Expanded(flex: 2, child: Text('AKSI', style: style)),
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
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

class _TableDataRow extends StatelessWidget {
  final KategoriOption row;
  final VoidCallback onEdit;
  final VoidCallback onHapus;

  const _TableDataRow({
    required this.row,
    required this.onEdit,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: AppColors.textPrimary, fontSize: 13);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text('#${row.id}', style: textStyle)),
        Expanded(
          flex: 3,
          child: Text(row.nama,
              style: textStyle.copyWith(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          flex: 5,
          child: Text(
            row.deskripsi,
            style: textStyle.copyWith(color: AppColors.textSecondary, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              _AksiIcon(
                icon: Icons.edit_outlined,
                color: AppColors.gold,
                tooltip: 'Ubah',
                onTap: onEdit,
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

/// Versi kartu dari satu baris kategori, dipakai saat layar sempit (HP).
class _CategoryCard extends StatelessWidget {
  final KategoriOption row;
  final VoidCallback onEdit;
  final VoidCallback onHapus;

  const _CategoryCard({
    required this.row,
    required this.onEdit,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
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
                    Text('#${row.id}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(row.nama,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              _AksiIcon(
                icon: Icons.edit_outlined,
                color: AppColors.gold,
                tooltip: 'Ubah',
                onTap: onEdit,
              ),
              _AksiIcon(
                icon: Icons.delete_outline,
                color: Colors.redAccent,
                tooltip: 'Hapus',
                onTap: onHapus,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            row.deskripsi,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}