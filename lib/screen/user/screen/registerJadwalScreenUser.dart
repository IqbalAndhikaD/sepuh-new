import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sepuh/screen/user/screen/homeScreenUser.dart';
import 'package:sepuh/screen/user/widget/botNavbarUser.dart';
import 'package:sepuh/widget/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../model/doctor.dart';

class registerJadwalScreenUser extends StatefulWidget {
  const registerJadwalScreenUser({Key? key}) : super(key: key);

  @override
  _registerJadwalScreenUserState createState() => _registerJadwalScreenUserState();
}

class _registerJadwalScreenUserState extends State<registerJadwalScreenUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<Map<String, String>> _dokter = [];
  String? _selectedDoctor;
  bool _isLoading = false;

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
        Uri.parse('https://sepuh-api.vercel.app/dokter'),
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
                'jadwal': (item['jadwal'] as List).map((jadwalItem) {
                  final jadwal = Jadwal.fromJson(jadwalItem);
                  return '${jadwal.hari}: ${jadwal.jamMulai} - ${jadwal.jamSelesai}';
                }).join('\n'),
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

  Future<void> registerPasien() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      print(_namaController.text);
      print(_tanggalController.text);
      print(_selectedDoctor);
      try {
        final response = await http.post(
          Uri.parse('https://sepuh-api.vercel.app/jadwal'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'pasien': _namaController.text,
            'waktu': _tanggalController.text,
            'dokter': _selectedDoctor,
          }),
        );

        if (response.statusCode == 200) {
          print('Registrasi pasien berhasil');
          print('Response body: ${response.body}');
          showSuccessModal();
        } else {
          print('Registrasi pasien gagal');
          print('Response status: ${response.statusCode}');
          print('Response body: ${response.body}');
          throw Exception('Failed to register patient');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('No token found');
      throw Exception('No token found');
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
                      MaterialPageRoute(builder: (context) => botNavbarUser(index: 0,)),
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
    _tanggalController.dispose();
    super.dispose();
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
          Padding(
            padding: EdgeInsets.only(top: 100, left: 30, right: 30),
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
              padding: EdgeInsets.only(top: 148, left: 20, right: 20),
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
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: biruNavy,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _namaController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: bg,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                              gapPadding: 4,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                              gapPadding: 4,
                            ),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama Lengkap tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Tanggal",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: biruNavy,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _tanggalController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: bg,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                              gapPadding: 4,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                              gapPadding: 4,
                            ),
                            labelText: 'YYYY-MM-DDTHH:mm',
                            labelStyle: TextStyle(
                              color: biruNavy,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                            suffixIcon: IconButton(
                              onPressed: () async {
                                final DateTime? pickedDate =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now()
                                      .subtract(Duration(days: 730)),
                                  lastDate:
                                      DateTime.now().add(Duration(days: 730)),
                                );
                                if (pickedDate != null) {
                                  final TimeOfDay? pickedTime =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (pickedTime != null) {
                                    final DateTime combinedDateTime = DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                    setState(() {
                                      _selectedDate = combinedDateTime;
                                      _selectedTime = pickedTime;
                                      _tanggalController.text =
                                          DateFormat("yyyy-MM-dd'T'HH:mm")
                                              .format(combinedDateTime);
                                    });
                                  }
                                }
                              },
                              icon: Icon(Icons.calendar_today),
                            ),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Dokter",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: biruNavy,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                        _isLoading
                            ? CircularProgressIndicator()
                            : DropdownButtonFormField<String>(
                                value: _selectedDoctor,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  filled: true,
                                  fillColor: bg,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 10),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                    gapPadding: 4,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                    gapPadding: 4,
                                  ),
                                ),
                                items: _dokter.map((doctor) {
                                  return DropdownMenuItem<String>(
                                    value: doctor['nama'],
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${doctor['nama']} - ${doctor['spesialisasi']}',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            color: biruNavy,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          doctor['jadwal']!,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            color: biruToska,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDoctor = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Dokter tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                        SizedBox(height: 14),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gbutton,
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                registerPasien();
                              }
                            },
                            child: Text(
                              'DAFTAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
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
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

