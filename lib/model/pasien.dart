class Pasien {
  final String id;
  final String nama;
  final String usia;
  final String alamat;

  Pasien({
    required this.id,
    required this.nama,
    required this.usia,
    required this.alamat,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) {
    return Pasien(
      id: json['_id'],
      nama: json['nama'],
      usia: json['usia'],
      alamat: json['alamat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nama': nama,
      'usia': usia,
      'alamat': alamat,
    };
  }
}