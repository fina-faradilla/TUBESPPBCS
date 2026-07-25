class KategoriOption {
  final int id;
  final String nama;

  const KategoriOption({required this.id, required this.nama});

  factory KategoriOption.fromJson(Map<String, dynamic> json) {
    return KategoriOption(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nama: json['nama_kategori']?.toString() ?? '-',
    );
  }
}
