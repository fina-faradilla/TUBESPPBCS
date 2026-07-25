import 'package:flutter/material.dart';
import '../../models/laporan_row.dart';
import '../../theme/app_colors.dart';
import '../../utils/auth_storage.dart';
import '../../utils/status_utils.dart';
import '../../utils/warga_laporan_api.dart';
import '../../widgets/sidebar_menu.dart';

/// Halaman "Riwayat Laporan Saya" — daftar seluruh laporan yang
/// pernah diajukan warga beserta status terkininya, diambil dari API
/// (/api/laporan — otomatis terfilter ke milik user yang login).
class RiwayatLaporanScreen extends StatefulWidget {
  const RiwayatLaporanScreen({super.key});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen> {
  final _searchController = TextEditingController();
  String _statusFilter = 'Semua Status';

  List<LaporanRow> _rows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muatData();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await WargaLaporanApi.fetchMine();
      if (!mounted) return;
      setState(() => _rows = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<LaporanRow> get _filteredList {
    final query = _searchController.text.trim().toLowerCase();
    return _rows.where((l) {
      final matchesQuery =
          query.isEmpty ||
          l.judul.toLowerCase().contains(query) ||
          l.alamat.toLowerCase().contains(query);
      final matchesStatus =
          _statusFilter == 'Semua Status' || l.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
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
    // Sesuaikan '/login' kalau nama route login publik di project-mu beda.
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filteredList;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SidebarMenu(
            activeItem: 'Riwayat Laporan Saya',
            onLogout: _logout,
            items: [
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
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _muatData,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
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
                        if (_loading && rows.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        else if (rows.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'Belum ada laporan yang cocok.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        else
                          for (final laporan in rows) _buildTableRow(laporan),
                        const SizedBox(height: 12),
                        Text(
                          'Menampilkan ${rows.length} dari ${_rows.length} laporan',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
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
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 18,
            ),
            hintText: 'Cari judul atau alamat laporan...',
          ),
        );
        final dropdown = DropdownButtonFormField<String>(
          value: _statusFilter,
          dropdownColor: AppColors.bgDark,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          items: [
            'Semua Status',
            ...kStatusOptions,
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _statusFilter = v ?? _statusFilter),
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(flex: 3, child: search),
              const SizedBox(width: 16),
              SizedBox(width: 200, child: dropdown),
            ],
          );
        }
        return Column(children: [search, const SizedBox(height: 12), dropdown]);
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
          Expanded(flex: 2, child: Text('ALAMAT', style: style)),
          Expanded(flex: 2, child: Text('TANGGAL', style: style)),
          Expanded(flex: 2, child: Text('STATUS', style: style)),
        ],
      ),
    );
  }

  Widget _buildTableRow(LaporanRow laporan) {
    return Padding(
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
              laporan.alamat,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              laporan.tanggal,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _StatusBadge(
              status: laporan.status,
              color: laporan.statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
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
