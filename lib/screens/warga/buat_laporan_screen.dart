import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/sidebar_menu.dart';

/// Halaman "Buat Laporan Baru" — form warga untuk melaporkan
/// kerusakan jalan, lengkap dengan foto bukti & lokasi GPS.
class BuatLaporanScreen extends StatefulWidget {
  const BuatLaporanScreen({super.key});

  @override
  State<BuatLaporanScreen> createState() => _BuatLaporanScreenState();
}

class _BuatLaporanScreenState extends State<BuatLaporanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _alamatController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String _kategori = 'Jalan Berlubang';
  String _tingkat = 'Ringan';

  // TODO: ganti dengan koordinat asli dari layanan lokasi perangkat.
  double? _latitude = -6.9147;
  double? _longitude = 107.6098;

  final List<String> _kategoriOptions = const [
    'Jalan Berlubang',
    'Aspal Retak',
    'Jalan Ambles',
    'Jembatan Rusak',
    'Lainnya',
  ];

  final List<String> _tingkatOptions = const ['Ringan', 'Sedang', 'Berat'];

  @override
  void dispose() {
    _judulController.dispose();
    _alamatController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: kirim data laporan ke backend / API.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dikirim')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Row(
        children: [
          SidebarMenu(
            activeItem: 'Buat Laporan',
            items: [
              SidebarMenuItem(
                label: 'Buat Laporan',
                icon: Icons.add_circle_outline,
                onTap: () {},
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
              child: Form(
                key: _formKey,
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
                      'BUAT LAPORAN BARU',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Isi detail kerusakan jalan selengkap mungkin agar '
                      'dinas dapat menindaklanjuti dengan cepat.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 760;
                        final formColumn = _buildFormColumn();
                        final sideColumn = _buildSideColumn();
                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: formColumn),
                              const SizedBox(width: 24),
                              Expanded(flex: 2, child: sideColumn),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            formColumn,
                            const SizedBox(height: 24),
                            sideColumn,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Kirim Laporan'),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                          ),
                          child: const Text('Batalkan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormColumn() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel('Judul Laporan'),
          TextFormField(
            controller: _judulController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Contoh: Jalan berlubang besar dekat pasar',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
          ),
          const SizedBox(height: 18),
          _FieldLabel('Kategori Kerusakan'),
          DropdownButtonFormField<String>(
            value: _kategori,
            dropdownColor: AppColors.bgDark,
            style: const TextStyle(color: AppColors.textPrimary),
            items: _kategoriOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _kategori = v ?? _kategori),
          ),
          const SizedBox(height: 18),
          _FieldLabel('Tingkat Kerusakan'),
          DropdownButtonFormField<String>(
            value: _tingkat,
            dropdownColor: AppColors.bgDark,
            style: const TextStyle(color: AppColors.textPrimary),
            items: _tingkatOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _tingkat = v ?? _tingkat),
          ),
          const SizedBox(height: 18),
          _FieldLabel('Alamat / Titik Lokasi'),
          TextFormField(
            controller: _alamatController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Jl. Merdeka No. 12, Kec. ...',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Alamat wajib diisi' : null,
          ),
          const SizedBox(height: 18),
          _FieldLabel('Deskripsi'),
          TextFormField(
            controller: _deskripsiController,
            maxLines: 4,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText:
                  'Jelaskan kondisi kerusakan, sejak kapan, dan dampaknya '
                  'bagi pengguna jalan...',
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Deskripsi wajib diisi'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSideColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel('Foto Bukti'),
              GestureDetector(
                onTap: () {
                  // TODO: buka image_picker untuk ambil/pilih foto.
                },
                child: Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.cardBorder,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          color: AppColors.textSecondary, size: 26),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(text: 'Tarik foto ke sini atau '),
                            TextSpan(
                              text: 'pilih file',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'JPG/PNG, maks. 5MB',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel('Pratinjau Lokasi'),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                // TODO: ganti dengan widget peta (flutter_map / google_maps_flutter).
                child: const Icon(Icons.location_on,
                    color: AppColors.gold, size: 34),
              ),
              const SizedBox(height: 8),
              Text(
                _latitude != null && _longitude != null
                    ? '$_latitude, $_longitude (otomatis dari GPS perangkat)'
                    : 'Lokasi belum terdeteksi',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}