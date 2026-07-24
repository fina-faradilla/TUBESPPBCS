import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/kategori.dart';
import '../../controllers/kategori_controller.dart';
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
  final KategoriController _controller = KategoriController.instance;

  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  List<Kategori> get _filteredRows {
    return _controller.rows.where((k) {
      return _query.isEmpty ||
          k.nama.toLowerCase().contains(_query) ||
          k.id.toLowerCase().contains(_query);
    }).toList();
  }

  Future<void> _tambahKategori() async {
    final result = await showKategoriFormDialog(context);
    if (result == null) return;
    _controller.tambahKategori(nama: result.nama, deskripsi: result.deskripsi);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori baru berhasil ditambahkan')),
      );
    }
  }

  Future<void> _ubahKategori(Kategori row) async {
    final result = await showKategoriFormDialog(context, existing: row);
    if (result == null) return;
    _controller.ubahKategori(row.id, nama: result.nama, deskripsi: result.deskripsi);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori berhasil diubah')),
      );
    }
  }

  Future<void> _hapusKategori(Kategori row) async {
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
          'Kategori "${row.nama}" (${row.id}) akan dihapus permanen. Lanjutkan?',
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
      _controller.hapusKategori(row.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filteredRows;

    return Scaffold(
      body: Row(
        children: [
          const Sidebar(currentRoute: '/admin/manage-category'),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBar(
                  breadcrumb: 'PORTAL ADMIN / DINAS',
                  title: 'KELOLA KATEGORI',
                  trailing: ElevatedButton.icon(
                    onPressed: _tambahKategori,
                    icon: const Icon(Icons.add, size: 16, color: Colors.black),
                    label: const Text('Tambah Kategori', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
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

                          const _TableHeaderRow(),
                          const Divider(color: AppColors.cardBorder, height: 24),

                          // Baris data
                          if (rows.isEmpty)
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
                              _TableDataRow(
                                row: rows[i],
                                onEdit: () => _ubahKategori(rows[i]),
                                onHapus: () => _hapusKategori(rows[i]),
                              ),
                              if (i != rows.length - 1)
                                const Divider(color: AppColors.cardBorder, height: 32),
                            ],

                          const SizedBox(height: 20),
                          Text(
                            'Menampilkan ${rows.length} dari ${_controller.total} kategori',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
  final Kategori row;
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
        Expanded(flex: 2, child: Text(row.id, style: textStyle)),
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