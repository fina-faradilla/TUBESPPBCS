/// Meniru `App\Models\TindakLanjut` (relasi hasMany dari Laporan).
class TindakLanjut {
  final int id;
  final String judul;
  final String keterangan;
  final DateTime createdAt;

  const TindakLanjut({
    required this.id,
    required this.judul,
    required this.keterangan,
    required this.createdAt,
  });
}
