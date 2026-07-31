import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/kategori_option.dart';
import '../models/laporan_row.dart';
import '../theme/app_colors.dart';
import '../utils/kategori_api.dart';
import '../utils/status_utils.dart'; // sumber tunggal kStatusOptions

class LaporanFormResult {
  final String judul;
  final String pelapor;
  final int kategoriId;
  final String tingkatKerusakan;
  final String status;
  final String deskripsi;
  final String alamat;
  final double? lat;
  final double? lng;
  final Uint8List? fotoBytes;
  final String? fotoFileName;

  const LaporanFormResult({
    required this.judul,
    required this.pelapor,
    required this.kategoriId,
    required this.tingkatKerusakan,
    required this.status,
    required this.deskripsi,
    required this.alamat,
    this.lat,
    this.lng,
    this.fotoBytes,
    this.fotoFileName,
  });
}

const List<String> kTingkatOptions = ['Ringan', 'Sedang', 'Berat'];

/// Titik tengah peta default (Bandung), dipakai kalau laporan baru
/// belum punya titik lokasi sama sekali.
const LatLng _kDefaultPoint = LatLng(-6.9175, 107.6191);

/// Format tanggal Indonesia sederhana, tanpa perlu package intl.
String _formatTanggalId(DateTime date) {
  const bulan = [
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
    'Des',
  ];
  return '${date.day} ${bulan[date.month - 1]} ${date.year}';
}

/// [existing] diisi dengan laporan yang sudah tersimpan kalau dialog
/// dibuka dalam mode "Ubah". Kosongkan (null) untuk mode "Tambah".
Future<LaporanFormResult?> showLaporanFormDialog(
  BuildContext context, {
  LaporanRow? existing,
}) {
  return showDialog<LaporanFormResult>(
    context: context,
    builder: (_) => _LaporanFormDialog(existing: existing),
  );
}

class _LaporanFormDialog extends StatefulWidget {
  final LaporanRow? existing;
  const _LaporanFormDialog({this.existing});

  @override
  State<_LaporanFormDialog> createState() => _LaporanFormDialogState();
}

class _LaporanFormDialogState extends State<_LaporanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulCtrl;
  late final TextEditingController _pelaporCtrl;
  late final TextEditingController _deskripsiCtrl;
  late final TextEditingController _alamatCtrl;

  // Kategori dari API
  List<KategoriOption> _kategoriOptions = [];
  bool _loadingKategori = true;
  String? _kategoriError;
  int? _kategoriId;

  // Kalau sedang mode edit, nama kategori laporan lama (dari LaporanRow)
  // dipakai buat mencocokkan ke KategoriOption yang benar setelah daftar
  // kategori selesai dimuat dari API (LaporanRow cuma nyimpan nama, bukan id).
  String? _kategoriNamaLama;

  late String _tingkat;
  late String _status;
  Uint8List? _fotoBytes;
  String? _fotoFileName;

  final MapController _mapController = MapController();

  late LatLng _selectedPoint;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;

  bool _isMencariLokasi = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();

    final e = widget.existing;
    _judulCtrl = TextEditingController(text: e?.judul ?? '');
    _pelaporCtrl = TextEditingController(text: e?.pelapor ?? '');
    _deskripsiCtrl = TextEditingController(text: e?.deskripsi ?? '');
    _alamatCtrl = TextEditingController(text: e?.alamat ?? '');

    // kategoriId belum diketahui langsung dari LaporanRow (cuma nyimpan
    // nama kategori) — dicocokkan ke id yang benar setelah _muatKategori().
    _kategoriNamaLama = e?.kategori;

    _tingkat = e?.tingkatKerusakan ?? kTingkatOptions.first;
    _status = e?.status ?? kStatusOptions.first;

    // Kalau sedang mengubah laporan yang sudah punya titik lokasi,
    // peta harus mulai dari titik itu — bukan selalu titik default.
    _selectedPoint = (e?.lat != null && e?.lng != null)
        ? LatLng(e!.lat!, e.lng!)
        : _kDefaultPoint;

    _latCtrl = TextEditingController(
      text: _selectedPoint.latitude.toStringAsFixed(6),
    );
    _lngCtrl = TextEditingController(
      text: _selectedPoint.longitude.toStringAsFixed(6),
    );

    // Muat kategori dari API
    _muatKategori();
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _pelaporCtrl.dispose();
    _deskripsiCtrl.dispose();
    _alamatCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
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
      setState(() {
        _kategoriOptions = data;
        _loadingKategori = false;

        if (_kategoriNamaLama != null) {
          // Mode edit: cocokkan nama kategori laporan lama ke id yang
          // sesuai. Kalau kategorinya sudah dihapus admin, biarkan null
          // supaya user pilih ulang.
          final match = data
              .where((k) => k.nama == _kategoriNamaLama)
              .toList();
          _kategoriId = match.isNotEmpty ? match.first.id : null;
        } else if (_kategoriId != null &&
            !data.any((k) => k.id == _kategoriId)) {
          _kategoriId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _kategoriError = e.toString();
        _loadingKategori = false;
      });
    }
  }

  /// Dipanggil saat titik diubah lewat tap di peta.
  void _onMapTap(LatLng point) {
    setState(() {
      _selectedPoint = point;
      _latCtrl.text = point.latitude.toStringAsFixed(6);
      _lngCtrl.text = point.longitude.toStringAsFixed(6);
    });
  }

  /// Dipanggil saat admin mengetik manual di kolom Latitude/Longitude,
  /// supaya peta & marker ikut pindah (sebelumnya tidak sinkron).
  void _onLatLngFieldChanged(String _) {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null) return;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return;

    final point = LatLng(lat, lng);
    setState(() => _selectedPoint = point);
    _mapController.move(point, _mapController.camera.zoom);
  }

  /// Cari koordinat dari teks alamat lewat Nominatim (OpenStreetMap) dan
  /// pindahkan titik peta ke hasil pertama yang ditemukan.
  Future<void> _cariLokasiDariAlamat() async {
    final query = _alamatCtrl.text.trim();
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
        headers: {'User-Agent': 'com.roadfix.app (admin-laporan-manual)'},
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
      setState(() {
        _selectedPoint = point;
        _latCtrl.text = lat.toStringAsFixed(6);
        _lngCtrl.text = lng.toStringAsFixed(6);
      });
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_kategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori kerusakan dulu.')),
      );
      return;
    }

    Navigator.pop(
      context,
      LaporanFormResult(
        judul: _judulCtrl.text.trim(),
        pelapor: _pelaporCtrl.text.trim().isEmpty
            ? 'Admin (manual)'
            : _pelaporCtrl.text.trim(),
        kategoriId: _kategoriId!,
        tingkatKerusakan: _tingkat,
        status: _status,
        deskripsi: _deskripsiCtrl.text.trim(),
        alamat: _alamatCtrl.text.trim(),
        lat: _selectedPoint.latitude,
        lng: _selectedPoint.longitude,
        fotoBytes: _fotoBytes,
        fotoFileName: _fotoFileName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tanggalHariIni = _formatTanggalId(DateTime.now());

    return Dialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  _isEdit ? 'Ubah Laporan' : 'Tambah Laporan Manual',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field('Judul Laporan', _judulCtrl, required: true),
                      _field(
                        'Nama Pelapor',
                        _pelaporCtrl,
                        hint: 'mis. Admin (manual)',
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _kategoriDropdown()),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _dropdown(
                              'Status',
                              _status,
                              kStatusOptions,
                              (v) => setState(() => _status = v!),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _dropdown(
                              'Tingkat Kerusakan',
                              _tingkat,
                              kTingkatOptions,
                              (v) => setState(() => _tingkat = v!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _readonlyTanggal(tanggalHariIni)),
                        ],
                      ),
                      _alamatField(),
                      _label('Titik Lokasi di Peta'),
                      const SizedBox(height: 4),
                      const Text(
                        'Ketuk peta, isi lat/lng manual, atau cari lewat '
                        'alamat di atas untuk menandai lokasi kerusakan.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),

                      SizedBox(
                        height: 260,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
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
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                              const RichAttributionWidget(
                                attributions: [
                                  TextSourceAttribution(
                                    '© OpenStreetMap contributors',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              'Latitude',
                              _latCtrl,
                              onChanged: _onLatLngFieldChanged,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field(
                              'Longitude',
                              _lngCtrl,
                              onChanged: _onLatLngFieldChanged,
                            ),
                          ),
                        ],
                      ),
                      _field(
                        'Deskripsi',
                        _deskripsiCtrl,
                        required: true,
                        maxLines: 3,
                        hint:
                            'Jelaskan kondisi kerusakan, sejak kapan, dan '
                            'dampaknya bagi pengguna jalan...',
                      ),
                      _label('Foto Kerusakan'),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            OutlinedButton(
                              onPressed: _pilihFoto,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              child: const Text(
                                'Choose File',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _fotoFileName ??
                                    (_isEdit
                                        ? 'Biarkan kosong untuk pakai foto lama'
                                        : 'No file chosen'),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.cardBorder),
                      ),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.black,
                        elevation: 0,
                      ),
                      child: Text(
                        _isEdit ? 'Simpan' : 'Tambah',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kategoriDropdown() {
    if (_loadingKategori) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Kategori'),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              height: 44,
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
            ),
          ],
        ),
      );
    }

    if (_kategoriError != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Kategori'),
            const SizedBox(height: 6),
            Container(
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
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Kategori'),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _kategoriId,
                isExpanded: true,
                hint: const Text(
                  'Pilih kategori',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                dropdownColor: AppColors.cardBg,
                iconEnabledColor: AppColors.textSecondary,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                items: _kategoriOptions
                    .map(
                      (k) => DropdownMenuItem(value: k.id, child: Text(k.nama)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _kategoriId = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readonlyTanggal(String tanggal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Tanggal'),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  tanggal,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
  );

  Widget _field(
    String label,
    TextEditingController ctrl, {
    bool required = false,
    int maxLines = 1,
    String? hint,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            maxLines: maxLines,
            onChanged: onChanged,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            validator: required
                ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              filled: true,
              fillColor: AppColors.bgDark,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _alamatField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Alamat'),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _alamatCtrl,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  decoration: InputDecoration(
                    hintText: 'mis. Jl. Merdeka No. 12, Bandung',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: AppColors.bgDark,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.gold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
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
        ],
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: AppColors.cardBg,
                iconEnabledColor: AppColors.textSecondary,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                items: options
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}