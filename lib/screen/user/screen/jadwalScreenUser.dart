// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import the jwt_decoder package

import '../../../widget/color.dart';

class jadwalScreenUser extends StatefulWidget {
  @override
  _jadwalScreenUserState createState() => _jadwalScreenUserState();
}

class _jadwalScreenUserState extends State<jadwalScreenUser> {
  List<Jadwal> jadwalList = [];
  bool isLoading = false;

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
      final response = await http.get(
        Uri.parse('https://sepuh-api.vercel.app/jadwal'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        jadwalList = (jsonData['data'] as List<dynamic>)
            .map((item) => Jadwal.fromJson(item))
            .toList();
        setState(() {
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
      appBar: AppBar(
        title: Text('Jadwal App'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: jadwalList.length,
              itemBuilder: (context, index) {
                Jadwal jadwal = jadwalList[index];
                return Card(
                  child: ListTile(
                    title: Text(jadwal.pasien!['nama']),
                    subtitle: Text(jadwal.dokter!['nama']),
                    trailing: Text(DateFormat('HH:mm').format(jadwal.waktu)),
                  ),
                );
              },
            ),
    );
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
waktu: parseWaktu(json['waktu']),   
   dokter: json['dokter'] ?? {},
      pasien: json['pasien'],
      status: json['status'],
    );
  }
}
DateTime parseWaktu(String waktuString) {
  return DateFormat('dd-MM-yyyy HH:mm').parse(waktuString);
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
