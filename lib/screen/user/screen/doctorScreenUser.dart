import 'package:flutter/material.dart';
import 'package:sepuh/model/doctor.dart';
import 'package:sepuh/widget/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  final List<Dokter> _dokter = [];
  bool _isLoading = false;

  Future<void> _fetchDokter() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('https://sepuh-api.vercel.app/user/dokter/'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          setState(() {
            _dokter.clear();
            for (var item in jsonData['data']) {
              _dokter.add(Dokter.fromJson(item));
            }
            _isLoading = false;
          });
        } else {
          print('Failed to load data: ${response.statusCode}');
          print('Response body: ${response.body}');
          setState(() {
            _isLoading = false;
          });
          throw Exception('Failed to load data');
        }
      } else {
        print('No token found');
        setState(() {
          _isLoading = false;
        });
        throw Exception('No token found');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDokter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [biruNavy, biruToska],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 112, left: 30, right: 30),
            child: Text(
              'Daftar Jadwal Dokter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 160, left: 20, right: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              constraints: const BoxConstraints(maxWidth: 500, minHeight: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _dokter.length,
                            itemBuilder: (BuildContext context, int index) {
                              final item = _dokter[index];
                              return Container(
                                height: 112,
                                margin: const EdgeInsets.only(
                                    bottom: 8, left: 16, right: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 2.0),
                                      blurRadius: 2.0,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Dr. ${item.nama}', 
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0XFF225374),
                                            ),
                                          ),
                                          Text(
                                            'Spesialis ${item.spesialisasi}', 
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: biruNavy,
                                                ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: item.jadwal.map((jadwal) {
                                              return Text(
                                                '${jadwal.hari}: ${jadwal.jamMulai} - ${jadwal.jamSelesai}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    ?.copyWith(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: biruToska,
                                                    ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
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
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}