/// Meniru `App\Models\TindakLanjut` (relasi hasMany dari Laporan).
class TindakLanjut {
  final int id;
  final String status; // 'Diproses' atau 'Selesai'
  final String catatan;
  final String? admin; // nama admin yang mengisi
  final DateTime createdAt;

  const TindakLanjut({
    required this.id,
    required this.status,
    required this.catatan,
    required this.createdAt,
    this.admin,
  });

  /// Parse dari relasi Laravel `App\Models\TindakLanjut` — key `tindak_lanjut`
  /// dikirim oleh `LaporanApiController@transform` (lihat [LaporanRow.fromJson]).
  factory TindakLanjut.fromJson(Map<String, dynamic> json) {
    return TindakLanjut(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      status: json['status'] ?? '',
      catatan: json['catatan'] ?? '',
      admin: json['admin'],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
