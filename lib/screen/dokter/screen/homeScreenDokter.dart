import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sepuh/screen/dokter/screen/ListPasienScreen.dart';
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
  List<Pasien> _pasien = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPasien();
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

  Future<void> _fetchPasien() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('https://sepuh-api.vercel.app/user/pasien'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _pasien.clear();
          for (var item in jsonData['data']) {
            _pasien.add(Pasien.fromJson(item));
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('No token found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Stack(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 32, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 20),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildFeatureButton(
                                      'List\nPasien', 'assets/registP.png'),
                                  _buildFeatureButton(
                                      'List\nJadwal', 'assets/schedule.png'),
                                  _buildFeatureButton(
                                      'Resep\nObat', 'assets/meds.png'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildPatientList(),
              ],
            ),
          ],
        ),
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
              if (label == 'List\nPasien') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ListPasienScreen()),
                );
              } else {
                // Do nothing for other features
                // You can add a print statement or show a snackbar to indicate that the feature is not yet implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur belum tersedia'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
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
          padding: const EdgeInsets.only(left: 32, top: 16),
          child: Text(
            "Schedule",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: biruNavy,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _pasien.length,
          itemBuilder: (context, index) {
            final patient = _pasien[index];
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
                  "${patient.usia} tahun",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: biruToska,
                  child: Text(
                    patient.nama[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                onTap: () => _showPatientInfo(patient),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showPatientInfo(Pasien pasien) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Informasi Pasien',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: biruNavy,
              fontFamily: 'Poppins',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nama: ${pasien.nama}'),
                Text('Usia: ${pasien.usia} tahun'),
                Text('Alamat: ${pasien.alamat ?? 'Tidak ada alamat'}'),
                Text('Riwayat:'),
                if (pasien.riwayat != null && pasien.riwayat!.isNotEmpty)
                  ...pasien.riwayat!.map((item) => Padding(
                        padding: EdgeInsets.only(left: 16, top: 4),
                        child: Text('• $item'),
                      ))
                else
                  Text('Tidak ada riwayat'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
