// ignore_for_file: unused_field, file_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sepuh/screen/user/screen/doctorScreenUser.dart';
import 'package:sepuh/screen/user/screen/jadwalScreenUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../model/doctor.dart';
import '../../../widget/color.dart';
import 'registerJadwalScreenUser.dart';
import 'package:http/http.dart' as http;

class HomeScreenUser extends StatefulWidget {
  const HomeScreenUser({super.key});

  @override
  State<HomeScreenUser> createState() => _HomeScreenUserState();
}

class _HomeScreenUserState extends State<HomeScreenUser> {
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
    _fetchName();
  }

  String _name = '';

  Future<void> _fetchName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        _name = decodedToken['nama'] ?? 'User';
      });
      if (kDebugMode) {
        print(decodedToken);
      }
    } else {
      if (kDebugMode) {
        print('No token found');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
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
            height: 256,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  child: Text(
                    'Hello,\n$_name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
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
                  constraints: BoxConstraints.loose(const Size.fromHeight(50)),
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
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 2.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints.tightFor(height: 160),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Padding(
                                padding: EdgeInsets.only(left: 16, bottom: 40)),
                            Text(
                              'Feature',
                              style: TextStyle(
                                  color: biruNavy,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins'),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: biruNavy,
                                    gradient: LinearGradient(
                                      colors: [biruNavy, biruToska],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const registerJadwalScreenUser(),
                                        ),
                                      );
                                    },
                                    icon: Image.asset(
                                      'assets/registP.png',
                                      width: 50,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Tambah\nPasien',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: biruNavy,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins'),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: biruNavy,
                                    gradient: LinearGradient(
                                      colors: [biruNavy, biruToska],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const DoctorScreen(),
                                        ),
                                      );
                                    },
                                    icon: Image.asset(
                                      'assets/doctor.png',
                                      width: 50,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Daftar\nDokter',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: biruNavy,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins'),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: biruNavy,
                                    gradient: LinearGradient(
                                      colors: [biruNavy, biruToska],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const jadwalScreenUser(),
                                        ),
                                      );
                                    },
                                    icon: Image.asset(
                                      'assets/schedule.png',
                                      width: 50,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Daftar\nPeriksa',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: biruNavy,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins'),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.only(top: 380),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daftar Dokter",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0XFF225374),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(width: 180),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Color(0XFF225374),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                          SizedBox(height: 8),
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
        ],
      ),
    );
  }
}