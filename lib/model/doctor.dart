class Jadwal {
  final String id;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final int kuota;

  Jadwal({
    required this.id,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.kuota,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: json['_id'],
      hari: json['hari'],
      jamMulai: json['jamMulai'],
      jamSelesai: json['jamSelesai'],
      kuota: json['kuota'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'hari': hari,
      'jamMulai': jamMulai,
      'jamSelesai': jamSelesai,
      'kuota': kuota,
    };
  }
}

class Dokter {
  final String id;
  final String nama;
  final String spesialisasi;
  final List<Jadwal> jadwal;

  Dokter({
    required this.id,
    required this.nama,
    required this.spesialisasi,
    required this.jadwal,
  });

  factory Dokter.fromJson(Map<String, dynamic> json) {
    return Dokter(
      id: json['_id'],
      nama: json['nama'],
      spesialisasi: json['spesialisasi'],
      jadwal: (json['jadwal'] as List<dynamic>?)
              ?.map((item) => Jadwal.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nama': nama,
      'spesialisasi': spesialisasi,
      'jadwal': jadwal.map((item) => item.toJson()).toList(),
    };
  }
}