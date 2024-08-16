// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import the jwt_decoder package

import '../../../widget/color.dart';

class jadwalScreenUser extends StatefulWidget {
  const jadwalScreenUser({super.key});

  @override
  State<jadwalScreenUser> createState() => _jadwalScreenUserState();
}

class _jadwalScreenUserState extends State<jadwalScreenUser> {
  List<Jadwal> jadwalList = [];
  bool isLoading = false;
  String? userName;

  @override
  void initState() {
    super.initState();
    fetchJadwal();
  }

  Future<void> fetchJadwal() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final userName = decodedToken['nama'];

      final response = await http.get(
        Uri.parse('https://sepuh-api.vercel.app/user/dokter/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        setState(() {
          jadwalList = (jsonData['data'] as List<dynamic>)
              .map((item) => Jadwal.fromJson(item))
              .where((jadwal) => jadwal.pasien?['nama'] == userName)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to fetch jadwal');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('No token found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                colors: [biruNavy, biruToska],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              color: biruNavy,
            ),
            width: double.infinity,
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 28),
                  child: Positioned(
                    top: 60,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Back',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 2.0),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: " Search",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: biruNavy),
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  constraints: BoxConstraints.loose(const Size.fromHeight(50)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 52, left: 12),
                  child: Text(
                    'Jadwal',
                    style: TextStyle(
                        color: biruNavy,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins'),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 252, left: 16, right: 16),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  const SizedBox(height: 10),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    for (var jadwal in jadwalList)
                      ScheduleCard(
                        status: jadwal.status,
                        time: DateFormat('HH:mm').format(jadwal.waktu),
                        date: DateFormat('MM/dd/yyyy').format(jadwal.waktu),
                        pasien: jadwal.pasien != null
                            ? jadwal.pasien!['nama']
                            : 'Belum ada pasien',
                        doctor:
                            '${jadwal.dokter['nama']} - ${jadwal.dokter['spesialisasi']}',
                        color: getStatusColor(jadwal.status),
                        iconColor: getStatusIconColor(jadwal.status),
                      ),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'disetujui':
        return Colors.grey;
      case 'ditolak':
        return const Color(0xFF225374);
      case 'diajukan':
      default:
        return const Color(0xFF225374);
    }
  }

  Color? getStatusIconColor(String status) {
    switch (status) {
      case 'disetujui':
        return Colors.grey[400];
      case 'ditolak':
        return Colors.red[400];
      case 'diajukan':
      default:
        return Colors.green[400];
    }
  }
}

class Jadwal {
  final String id;
  final DateTime waktu;
  final Map<String, dynamic> dokter;
  final Map<String, dynamic>? pasien;
  final String status;

  Jadwal({
    required this.id,
    required this.waktu,
    required this.dokter,
    this.pasien,
    required this.status,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: json['_id'],
      waktu: DateTime.parse(json['waktu']),
      dokter: json['dokter'] ?? {},
      pasien: json['pasien'],
      status: json['status'],
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String status;
  final String time;
  final String date;
  final String pasien;
  final String doctor;
  final Color color;
  final Color? iconColor;

  const ScheduleCard({
    super.key,
    required this.status,
    required this.time,
    required this.date,
    required this.pasien,
    required this.doctor,
    required this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.circle, color: iconColor, size: 14),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 5),
                    Text(time, style: const TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 5),
                    Text(date, style: const TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white, size: 16),
                    const SizedBox(width: 5),
                    Text(pasien, style: const TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.medical_information,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 5),
                    Text(doctor, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
