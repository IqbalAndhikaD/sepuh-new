class Pasien {
  final String id;
  final String nama;
  final String usia;
  final String? alamat;
  final List<dynamic>? riwayat;

  Pasien({
    required this.id,
    required this.nama,
    required this.usia,
    required this.alamat,
    this.riwayat,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) {
    return Pasien(
      id: json['_id'],
      nama: json['nama'],
      usia: json['usia'].toString(),
      alamat: json['alamat'],
      riwayat: json['riwayat'] as List<dynamic>?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nama': nama,
      'usia': usia,
      'alamat': alamat,
      'riwayat' : riwayat
    };
  }
}
