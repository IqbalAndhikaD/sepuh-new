import 'package:flutter/material.dart';
import 'package:sepuh/screen/user/widget/botNavbarUser.dart';
import 'package:sepuh/widget/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class registerJadwalScreenUser extends StatefulWidget {
  const registerJadwalScreenUser({Key? key}) : super(key: key);

  @override
  _registerJadwalScreenUserState createState() =>
      _registerJadwalScreenUserState();
}

class _registerJadwalScreenUserState extends State<registerJadwalScreenUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  List<Map<String, String>> _dokter = [];
  String? _selectedDoctor;
  String? _selectedDay;
  String? _selectedScheduleId;
  bool _isLoading = false;
  List<Map<String, dynamic>> _availableTimes = [];
  Map<String, dynamic>? _selectedTime;
  String? _selectedDoctorSpecialization;

  @override
  void initState() {
    super.initState();
    _fetchName();
    _fetchDoctors();
  }

  Future<void> _fetchName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      // Decode the token
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        _namaController.text = decodedToken['nama'] ?? 'User';
      });
    } else {
      print('No token found');
    }
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _isLoading = true;
    });

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
          _dokter = [
            for (var item in jsonData['data'])
              {
                'nama': item['nama'] as String,
                'spesialisasi': item['spesialisasi'] as String,
                'jadwal': jsonEncode(item['jadwal']),
              }
          ];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load doctors');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('No token found');
    }
  }

  void _onDoctorSelected(String? doctor) {
    if (doctor != null) {
      final selectedDoctor =
          _dokter.firstWhere((element) => element['nama'] == doctor);
      final jadwal = jsonDecode(selectedDoctor['jadwal']!);

      _availableTimes = jadwal
          .map<Map<String, dynamic>>((jadwalItem) => {
                'hari': jadwalItem['hari'],
                'jamMulai': jadwalItem['jamMulai'],
                'jamSelesai': jadwalItem['jamSelesai'],
                'id': jadwalItem['_id'],
              })
          .toList();

      setState(() {
        _selectedDoctor = doctor;
        _selectedDoctorSpecialization = selectedDoctor['spesialisasi'];
        _selectedTime = null;
      });
    }
  }

  Future<void> registerPasien() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('https://sepuh-api.vercel.app/jadwal'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'pasien': _namaController.text,
            'dokter': _selectedDoctor,
            'waktu': _selectedTime!['id'],
          }),
        );
          print(_selectedTime!);

        if (response.statusCode == 200) {
          print('Registrasi pasien berhasil');
          print('Response body: ${response.body}');
          showSuccessModal();
        } else {
          print('Registrasi pasien gagal');
          final errorMessage = jsonDecode(response.body)['message'] ??
              'Terjadi kesalahan saat registrasi';
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('No token found or no time selected');
      throw Exception('No token found or no time selected');
    }
  }

  void showSuccessModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 500,
          width: 500,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Image.asset(
                    'assets/success.png',
                    width: 250,
                    height: 250,
                  ),
                ),
                Text(
                  'Registrasi Pasien Berhasil!!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: biruNavy,
                  ),
                ),
                Text(
                  'Sekarang kamu bisa kembali pada beranda',
                  style: TextStyle(color: biruNavy),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gbutton,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => botNavbarUser(
                                index: 0,
                              )),
                    );
                  },
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: biruNavy,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Text(
              "Registrasi Pasien",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 60, left: 20, right: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                constraints: BoxConstraints.loose(Size.fromHeight(700)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 8),
                        Text(
                          "Nama Lengkap",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _namaController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nama Lengkap',
                          ),
                          readOnly: true,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Pilih Dokter",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedDoctor,
                          onChanged: _onDoctorSelected,
                          items: _dokter
                              .map((item) => DropdownMenuItem<String>(
                                    value: item['nama'],
                                    child: Text(
                                        "${item['nama']} - Spesialis ${item['spesialisasi']}"),
                                  ))
                              .toList(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Pilih Dokter',
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Pilih Waktu",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<Map<String, dynamic>>(
                          value: _selectedTime,
                          onChanged: (value) {
                            setState(() {
                              _selectedTime = value;
                              _selectedScheduleId = value?['id'];
                            });
                          },
                          items: _availableTimes
                              .map((time) =>
                                  DropdownMenuItem<Map<String, dynamic>>(
                                    value: time,
                                    child: Text(
                                        "${time['hari']} (${time['jamMulai']} - ${time['jamSelesai']})"),
                                  ))
                              .toList(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Pilih Waktu',
                          ),
                        ),
                        SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                registerPasien();
                              }
                            },
                            child: Text('Registrasi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gbutton,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 48, vertical: 12),
                              textStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
