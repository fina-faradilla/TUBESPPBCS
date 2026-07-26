/// Model data untuk satu laporan kerusakan jalan.
class Laporan {
  final String id; // contoh: RF-2026-0143
  final String judul;
  final String lokasi;
  final String deskripsi;
  final String kategori; // Jalan Berlubang, Aspal Retak, dll
  final String tingkat; // Ringan, Sedang, Berat
  final String status; // BARU, DIPROSES, SELESAI, DITOLAK
  final DateTime tanggal;
  final String? fotoUrl;
  final double? latitude;
  final double? longitude;
  final List<RiwayatTindakLanjut> riwayat;

  const Laporan({
    required this.id,
    required this.judul,
    required this.lokasi,
    required this.deskripsi,
    required this.kategori,
    required this.tingkat,
    required this.status,
    required this.tanggal,
    this.fotoUrl,
    this.latitude,
    this.longitude,
    this.riwayat = const [],
  });

  factory Laporan.fromJson(Map<String, dynamic> json) {
    return Laporan(
      id: json['id'] as String,
      judul: json['judul'] as String,
      lokasi: json['lokasi'] as String,
      deskripsi: json['deskripsi'] as String? ?? '',
      kategori: json['kategori'] as String? ?? '',
      tingkat: json['tingkat'] as String? ?? 'Ringan',
      status: json['status'] as String? ?? 'BARU',
      tanggal: DateTime.parse(json['tanggal'] as String),
      fotoUrl: json['foto_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      riwayat: (json['riwayat'] as List<dynamic>? ?? [])
          .map((e) => RiwayatTindakLanjut.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Satu entri di timeline "Riwayat Tindak Lanjut".
class RiwayatTindakLanjut {
  final DateTime waktu;
  final String judul;
  final String keterangan;

  const RiwayatTindakLanjut({
    required this.waktu,
    required this.judul,
    required this.keterangan,
  });

  factory RiwayatTindakLanjut.fromJson(Map<String, dynamic> json) {
    return RiwayatTindakLanjut(
      waktu: DateTime.parse(json['waktu'] as String),
      judul: json['judul'] as String,
      keterangan: json['keterangan'] as String,
    );
  }
}