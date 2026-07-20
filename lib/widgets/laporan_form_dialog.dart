import 'package:flutter/material.dart';
import '../models/laporan_row.dart';
import '../theme/app_colors.dart';
import '../utils/status_utils.dart';

/// Hasil submit form: judul, pelapor, kategori, status, tanggal.
class LaporanFormResult {
  final String judul;
  final String pelapor;
  final String kategori;
  final String status;
  final String tanggal;
  final String tingkatKerusakan;
  final String alamat;
  final String deskripsi;

  LaporanFormResult({
    required this.judul,
    required this.pelapor,
    required this.kategori,
    required this.status,
    required this.tanggal,
    required this.tingkatKerusakan,
    required this.alamat,
    required this.deskripsi,
  });
}

/// Menampilkan dialog form tambah/ubah laporan.
/// Jika [existing] diisi maka form dalam mode "Ubah", jika null mode "Tambah".
Future<LaporanFormResult?> showLaporanFormDialog(
  BuildContext context, {
  LaporanRow? existing,
}) {
  return showDialog<LaporanFormResult>(
    context: context,
    builder: (context) => _LaporanFormDialog(existing: existing),
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
  late final TextEditingController _tanggalCtrl;
  late final TextEditingController _alamatCtrl;
  late final TextEditingController _deskripsiCtrl;
  late String _kategori;
  late String _status;
  late String _tingkatKerusakan;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _judulCtrl = TextEditingController(text: e?.judul ?? '');
    _pelaporCtrl = TextEditingController(text: e?.pelapor ?? '');
    _tanggalCtrl = TextEditingController(
      text: e?.tanggal ?? formatTanggal(DateTime.now()),
    );
    _alamatCtrl = TextEditingController(text: e?.alamat ?? '');
    _deskripsiCtrl = TextEditingController(text: e?.deskripsi ?? '');
    _kategori = e?.kategori ?? kKategoriOptions.first;
    _status = e?.status ?? kStatusOptions.first;
    _tingkatKerusakan = e?.tingkatKerusakan ?? kTingkatKerusakanOptions.first;
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _pelaporCtrl.dispose();
    _tanggalCtrl.dispose();
    _alamatCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: AppColors.bgDark,
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
    );
  }

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: Colors.black,
              surface: AppColors.cardBg,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _tanggalCtrl.text = formatTanggal(picked));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      LaporanFormResult(
        judul: _judulCtrl.text.trim(),
        pelapor: _pelaporCtrl.text.trim(),
        kategori: _kategori,
        status: _status,
        tanggal: _tanggalCtrl.text.trim(),
        tingkatKerusakan: _tingkatKerusakan,
        alamat: _alamatCtrl.text.trim().isEmpty ? '-' : _alamatCtrl.text.trim(),
        deskripsi: _deskripsiCtrl.text.trim().isEmpty
            ? '-'
            : _deskripsiCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 460,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Ubah Laporan' : 'Tambah Laporan Manual',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _judulCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _decoration('Judul Laporan'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _pelaporCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _decoration('Nama Pelapor'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Pelapor wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _kategori,
                        dropdownColor: AppColors.cardBg,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: _decoration('Kategori'),
                        items: kKategoriOptions
                            .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                            .toList(),
                        onChanged: (v) => setState(() => _kategori = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _status,
                        dropdownColor: AppColors.cardBg,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: _decoration('Status'),
                        items: kStatusOptions
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _tingkatKerusakan,
                        dropdownColor: AppColors.cardBg,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: _decoration('Tingkat Kerusakan'),
                        items: kTingkatKerusakanOptions
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setState(() => _tingkatKerusakan = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _tanggalCtrl,
                        readOnly: true,
                        onTap: _pickTanggal,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _decoration('Tanggal').copyWith(
                          suffixIcon: const Icon(Icons.calendar_today,
                              size: 16, color: AppColors.textSecondary),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Tanggal wajib diisi'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _alamatCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _decoration('Alamat'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Alamat wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _deskripsiCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _decoration('Deskripsi'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Deskripsi wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Batal',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isEdit ? 'Simpan Perubahan' : 'Tambah',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
