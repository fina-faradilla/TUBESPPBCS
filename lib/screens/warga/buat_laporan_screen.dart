import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../models/kategori_option.dart';
import '../../theme/app_colors.dart';
import '../../utils/auth_storage.dart';
import '../../utils/kategori_api.dart';
import '../../utils/warga_laporan_api.dart';
import '../../utils/responsive.dart';
import '../../widgets/sidebar_menu.dart';

/// Halaman "Buat Laporan Baru" — form warga untuk melaporkan
/// kerusakan jalan, lengkap dengan foto bukti & lokasi di peta.
class BuatLaporanScreen extends StatefulWidget {
  const BuatLaporanScreen({super.key});

  @override
  State<BuatLaporanScreen> createState() => _BuatLaporanScreenState();
}

const List<String> _kTingkatOptions = ['Ringan', 'Sedang', 'Berat'];

/// Titik tengah peta default (Bandung) sebelum warga menandai lokasi asli.
const LatLng _kDefaultPoint = LatLng(-6.9175, 107.6191);

class _BuatLaporanScreenState extends State<BuatLaporanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _alamatController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String _tingkat = _kTingkatOptions.first;

  // --- Kategori: diambil dari API (/api/kategori) ---
  List<KategoriOption> _kategoriOptions = [];
  int? _kategoriId;
  bool _loadingKategori = true;
  String? _kategoriError;

  // --- Lokasi: peta interaktif, bisa ditandai lewat tap atau cari alamat ---
  final MapController _mapController = MapController();
  LatLng _selectedPoint = _kDefaultPoint;
  bool _isMencariLokasi = false;

  // --- Foto bukti ---
  Uint8List? _fotoBytes;
  String? _fotoFileName;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _muatKategori();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _alamatController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _muatKategori() async {
    setState(() {
      _loadingKategori = true;
      _kategoriError = null;
    });
    try {
      final data = await KategoriApi.fetchAll();
      if (!mounted) return;
      setState(() => _kategoriOptions = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _kategoriError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingKategori = false);
    }
  }

  void _onMapTap(LatLng point) {
    setState(() => _selectedPoint = point);
  }

  /// Cari koordinat dari teks alamat lewat Nominatim (OpenStreetMap).
  Future<void> _cariLokasiDariAlamat() async {
    final query = _alamatController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi alamat dulu sebelum mencari.')),
      );
      return;
    }

    setState(() => _isMencariLokasi = true);
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'json',
        'limit': '1',
        'countrycodes': 'id',
      });

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'com.roadfix.app (warga-buat-laporan)'},
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menghubungi layanan pencarian lokasi');
      }

      final List<dynamic> hasil = jsonDecode(response.body);
      if (hasil.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi tidak ditemukan, coba perjelas alamatnya.'),
          ),
        );
        return;
      }

      final lat = double.parse(hasil.first['lat'] as String);
      final lng = double.parse(hasil.first['lon'] as String);
      final point = LatLng(lat, lng);

      if (!mounted) return;
      setState(() => _selectedPoint = point);
      _mapController.move(point, 16);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mencari lokasi. Periksa koneksi internet.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isMencariLokasi = false);
    }
  }

  Future<void> _pilihFoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.single;
    setState(() {
      _fotoBytes = f.bytes;
      _fotoFileName = f.name;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_kategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori kerusakan dulu.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await WargaLaporanApi.create(
        judul: _judulController.text.trim(),
        kategoriId: _kategoriId!,
        tingkatKerusakan: _tingkat,
        deskripsi: _deskripsiController.text.trim(),
        alamat: _alamatController.text.trim(),
        lat: _selectedPoint.latitude,
        lng: _selectedPoint.longitude,
        fotoBytes: _fotoBytes,
        fotoFileName: _fotoFileName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Laporan berhasil dikirim')));
      Navigator.of(context).pushReplacementNamed('/warga/riwayat-laporan');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim laporan: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
    final bool mobile = isMobileWidth(context);

    final sidebarItems = [
      SidebarMenuItem(
        label: 'Buat Laporan',
        icon: Icons.add_circle_outline,
        onTap: () {},
      ),
      SidebarMenuItem(
        label: 'Riwayat Laporan Saya',
        icon: Icons.history,
        onTap: () => Navigator.of(
          context,
        ).pushReplacementNamed('/warga/riwayat-laporan'),
      ),
    ];

    final Widget content = SingleChildScrollView(
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
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Kirim Laporan'),
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
    );

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
            activeItem: 'Buat Laporan',
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
            activeItem: 'Buat Laporan',
            onLogout: _logout,
            items: sidebarItems,
          ),
          Expanded(child: content),
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
          _kategoriDropdown(),
          const SizedBox(height: 18),
          _FieldLabel('Tingkat Kerusakan'),
          DropdownButtonFormField<String>(
            value: _tingkat,
            dropdownColor: AppColors.bgDark,
            style: const TextStyle(color: AppColors.textPrimary),
            items: _kTingkatOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _tingkat = v ?? _tingkat),
          ),
          const SizedBox(height: 18),
          _FieldLabel('Alamat / Titik Lokasi'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _alamatController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Jl. Merdeka No. 12, Kec. ...',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Alamat wajib diisi'
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isMencariLokasi ? null : _cariLokasiDariAlamat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: _isMencariLokasi
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.search, size: 20),
                ),
              ),
            ],
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

  Widget _kategoriDropdown() {
    if (_loadingKategori) {
      return Container(
        width: double.infinity,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_kategoriError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.redAccent),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Gagal memuat kategori.',
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: _muatKategori,
              child: const Text('Coba Lagi', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int>(
      value: _kategoriId,
      dropdownColor: AppColors.bgDark,
      style: const TextStyle(color: AppColors.textPrimary),
      hint: const Text(
        'Pilih kategori',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      items: _kategoriOptions
          .map((k) => DropdownMenuItem(value: k.id, child: Text(k.nama)))
          .toList(),
      onChanged: (v) => setState(() => _kategoriId = v),
      validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
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
                onTap: _pilihFoto,
                child: Container(
                  height: 130,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.cardBorder,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _fotoBytes != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(_fotoBytes!, fit: BoxFit.cover),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _fotoBytes = null;
                                  _fotoFileName = null;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.textSecondary,
                              size: 26,
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(text: 'Klik untuk '),
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
              _FieldLabel('Titik Lokasi'),
              const SizedBox(height: 4),
              const Text(
                'Ketuk peta atau pakai tombol cari di kolom alamat.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 180,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedPoint,
                      initialZoom: 14,
                      onTap: (tapPosition, point) => _onMapTap(point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.roadfix.app',
                        maxZoom: 19,
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPoint,
                            width: 36,
                            height: 36,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                      const RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution('© OpenStreetMap contributors'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedPoint.latitude.toStringAsFixed(6)}, '
                '${_selectedPoint.longitude.toStringAsFixed(6)}',
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
