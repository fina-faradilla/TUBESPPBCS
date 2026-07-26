/// Meniru `App\Models\Kategori` pada versi web Laravel (master data
/// kategori kerusakan yang dipakai saat pelapor membuat laporan baru).
class Kategori {
  final String id;
  final String nama;
  final String deskripsi;

  const Kategori({
    required this.id,
    required this.nama,
    this.deskripsi = '-',
  });

  Kategori copyWith({
    String? id,
    String? nama,
    String? deskripsi,
  }) {
    return Kategori(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
    );
  }
}