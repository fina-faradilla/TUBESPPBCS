import 'package:flutter/material.dart';
import '../models/kategori.dart';
import '../theme/app_colors.dart';

/// Hasil submit form: nama & deskripsi kategori.
class KategoriFormResult {
  final String nama;
  final String deskripsi;

  KategoriFormResult({required this.nama, required this.deskripsi});
}

/// Menampilkan dialog form tambah/ubah kategori.
/// Jika [existing] diisi maka form dalam mode "Ubah", jika null mode "Tambah".
Future<KategoriFormResult?> showKategoriFormDialog(
  BuildContext context, {
  Kategori? existing,
}) {
  return showDialog<KategoriFormResult>(
    context: context,
    builder: (context) => _KategoriFormDialog(existing: existing),
  );
}

class _KategoriFormDialog extends StatefulWidget {
  final Kategori? existing;
  const _KategoriFormDialog({this.existing});

  @override
  State<_KategoriFormDialog> createState() => _KategoriFormDialogState();
}

class _KategoriFormDialogState extends State<_KategoriFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _deskripsiCtrl;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _namaCtrl = TextEditingController(text: e?.nama ?? '');
    _deskripsiCtrl = TextEditingController(text: e?.deskripsi ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      KategoriFormResult(
        nama: _namaCtrl.text.trim(),
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
          maxWidth: 420,
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
                  isEdit ? 'Ubah Kategori' : 'Tambah Kategori',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _namaCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _decoration('Nama Kategori'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _deskripsiCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _decoration('Deskripsi (opsional)'),
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