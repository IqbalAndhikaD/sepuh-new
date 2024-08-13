class Jadwal {
  final String hari;
  final String jamMulai;
  final String jamSelesai;

  Jadwal({
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      hari: json['hari'],
      jamMulai: json['jamMulai'],
      jamSelesai: json['jamSelesai'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hari': hari,
      'jamMulai': jamMulai,
      'jamSelesai': jamSelesai,
    };
  }
}

class Dokter {
  final String nama;
  final String spesialisasi;
  final List<Jadwal> jadwal;


  Dokter({
    required this.nama,
    required this.spesialisasi,
    required this.jadwal,

  });

  factory Dokter.fromJson(Map<String, dynamic> json) {
    return Dokter(
      nama: json['nama'],
      spesialisasi: json['spesialisasi'],
      jadwal: List<Jadwal>.from(json['jadwal'].map((item) => Jadwal.fromJson(item))),

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'spesialisasi': spesialisasi,
      'jadwal': jadwal.map((item) => item.toJson()).toList(),

    };
  }
}