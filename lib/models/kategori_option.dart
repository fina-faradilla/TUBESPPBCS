/// Satu opsi kategori dari backend (dipakai dropdown kategori di form
/// Tambah/Ubah Laporan, dan halaman Kelola Kategori). Berbeda dari model
/// `Kategori` lokal yang lama — `id` di sini `int`, sesuai primary key
/// di database.
class KategoriOption {
  final int id;
  final String nama;
  final String deskripsi;

  const KategoriOption({
    required this.id,
    required this.nama,
    this.deskripsi = '-',
  });

  factory KategoriOption.fromJson(Map<String, dynamic> json) {
    return KategoriOption(
      id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
      nama: json['nama_kategori']?.toString() ?? '-',
      deskripsi: (json['deskripsi'] as String?)?.trim().isNotEmpty == true
          ? json['deskripsi'] as String
          : '-',
    );
  }
}