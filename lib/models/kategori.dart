/// Meniru `App\Models\KategoriKerusakan` di backend Laravel (master data
/// kategori kerusakan yang dipakai saat pelapor membuat laporan baru).
class Kategori {
  final int id;
  final String nama;
  final String deskripsi;

  const Kategori({
    required this.id,
    required this.nama,
    this.deskripsi = '-',
  });

  /// Kode tampilan bergaya "KTG-0001" supaya konsisten dengan desain UI
  /// yang sudah ada, walau di database ID-nya cuma angka biasa.
  String get kodeTampilan => 'KTG-${id.toString().padLeft(4, '0')}';

  factory Kategori.fromJson(Map<String, dynamic> json) {
    final rawDeskripsi = json['deskripsi']?.toString().trim();
    return Kategori(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      nama: json['nama_kategori']?.toString() ?? '-',
      deskripsi: (rawDeskripsi == null || rawDeskripsi.isEmpty) ? '-' : rawDeskripsi,
    );
  }

  Kategori copyWith({
    int? id,
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