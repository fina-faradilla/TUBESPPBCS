import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Hasil submit form: judul & keterangan tindak lanjut.
class TindakLanjutFormResult {
  final String judul;
  final String keterangan;

  TindakLanjutFormResult({required this.judul, required this.keterangan});
}

/// Menampilkan dialog form "Tambah Tindak Lanjut" untuk sebuah laporan.
Future<TindakLanjutFormResult?> showTindakLanjutFormDialog(
  BuildContext context,
) {
  return showDialog<TindakLanjutFormResult>(
    context: context,
    builder: (context) => const _TindakLanjutFormDialog(),
  );
}

class _TindakLanjutFormDialog extends StatefulWidget {
  const _TindakLanjutFormDialog();

  @override
  State<_TindakLanjutFormDialog> createState() =>
      _TindakLanjutFormDialogState();
}

class _TindakLanjutFormDialogState extends State<_TindakLanjutFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _keteranganCtrl = TextEditingController();

  @override
  void dispose() {
    _judulCtrl.dispose();
    _keteranganCtrl.dispose();
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
      TindakLanjutFormResult(
        judul: _judulCtrl.text.trim(),
        keterangan: _keteranganCtrl.text.trim(),
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
                const Text(
                  'Tambah Tindak Lanjut',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Catat perkembangan penanganan untuk laporan ini.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _judulCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _decoration('Judul Tindak Lanjut'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _keteranganCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _decoration('Keterangan'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Keterangan wajib diisi'
                      : null,
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
                      child: const Text(
                        'Tambah',
                        style: TextStyle(color: Colors.black),
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