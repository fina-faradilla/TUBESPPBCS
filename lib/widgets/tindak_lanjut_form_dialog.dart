import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Hasil submit form: status baru & catatan tindak lanjut.
class TindakLanjutFormResult {
  final String status;
  final String catatan;

  TindakLanjutFormResult({required this.status, required this.catatan});
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
  final _catatanCtrl = TextEditingController();
  String _status = 'Diproses';

  static const List<String> _statusOptions = ['Diproses', 'Selesai'];

  @override
  void dispose() {
    _catatanCtrl.dispose();
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
        status: _status,
        catatan: _catatanCtrl.text.trim(),
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
                DropdownButtonFormField<String>(
                  value: _status,
                  dropdownColor: AppColors.cardBg,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _decoration('Status Baru'),
                  items: _statusOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _status = v);
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _catatanCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _decoration('Catatan'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Catatan wajib diisi'
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