import '../../../model/pasien.dart';
import '../../../model/doctor.dart';

class Schedule {
  final Waktu waktu;
  final Pasien pasien;
  final int antrian;
  final bool status;
  final Dokter dokter;

  Schedule({
    required this.waktu,
    required this.pasien,
    required this.antrian,
    required this.status,
    required this.dokter,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      waktu: Waktu.fromJson(json['waktu']),
      pasien: Pasien.fromJson(json['pasien']),
      antrian: json['antrian'],
      status: json['status'],
      dokter: Dokter.fromJson(json['dokter']),
    );
  }

  Object? toJson() {
    return null;
  }
}

class Waktu {
  final String hari;
  final String jamMulai;
  final String jamSelesai;

  Waktu({required this.hari, required this.jamMulai, required this.jamSelesai});

  factory Waktu.fromJson(Map<String, dynamic> json) {
    return Waktu(
      hari: json['hari'],
      jamMulai: json['jamMulai'],
      jamSelesai: json['jamSelesai'],
    );
  }
}