import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/pasien.dart';
import '../../../widget/color.dart';


class homeScreenDokter extends StatefulWidget {
  const homeScreenDokter({Key? key}) : super(key: key);

  @override
  State<homeScreenDokter> createState() => _homeScreenDokterState();
}

class _homeScreenDokterState extends State<homeScreenDokter> {
  List<Pasien> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
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

  Future<void> _fetchPatients() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response =
          await http.get(Uri.parse('https://sepuh-api.vercel.app/user/all/:id'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('API Response: $jsonData'); // Add this line for debugging
        setState(() {
          _patients = (jsonData['data']['data'] as List)
              .map((item) => Pasien.fromJson(item))
              .toList();
          _isLoading = false;
        });
        print('Parsed Patients: $_patients'); // Add this line for debugging
      } else {
        throw Exception('Failed to load patients');
      }
    } catch (e) {
      print('Error fetching patients: $e');
      setState(() {
        _isLoading = false;
      });
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  child: Text(
                    'Hello,\nDr. $_name',
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
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: biruNavy),
                      hintStyle: const TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feature',
                          style: TextStyle(
                            color: biruNavy,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeatureButton(
                                'List\nPasien', 'assets/registP.png'),
                            _buildFeatureButton(
                                'List\nJadwal', 'assets/schedule.png'),
                            _buildFeatureButton(
                                'Tambah\nobat', 'assets/meds.png'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 380,
            left: 0,
            right: 0,
            bottom: 0,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildPatientList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(String label, String iconPath) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [biruNavy, biruToska],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: IconButton(
            onPressed: () {
              // Handle button press
            },
            icon: Image.asset(iconPath, width: 50),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: biruNavy,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildPatientList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 36),
          child: Text(
            "Daftar Pasien",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: biruNavy,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _patients.length,
            itemBuilder: (context, index) {
              final patient = _patients[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    patient.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: biruNavy,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  subtitle: Text(
                    'Usia: ${patient.usia}',
                    style: TextStyle(
                      color: biruToska,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}