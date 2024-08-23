import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sepuh/screen/dokter/widget/botNavbarDokter.dart';
import 'package:sepuh/widget/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class assignMedicineScreen extends StatefulWidget {
  const assignMedicineScreen({Key? key}) : super(key: key);

  @override
  _assignMedicineScreenState createState() => _assignMedicineScreenState();
}

class _assignMedicineScreenState extends State<assignMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _pasienController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _rujukanController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<Map<String, String>> _medicine = [];
  // String? _selectedMedicine;
  List<String> _selectedMedicines = []; // Change this to a list
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchName();
    _fetchMedicines();
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

  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('https://sepuh-api.vercel.app/obat'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _medicine = [
            for (var item in jsonData['data'])
              {
                'nama': item['nama'] as String,
              }
          ];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load medicines');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('No token found');
    }
  }

  Future<void> assignmedicine() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      print(_pasienController.text);
      print(_selectedMedicines);
      print(_tanggalController.text);
      print(_namaController.text);
      print(_rujukanController);
      try {
        final response = await http.post(
          Uri.parse('https://sepuh-api.vercel.app/resep'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'pasien': _pasienController.text,
            // 'obat': selectedMedicinesString,
            // 'obat': _medicine,
            'obat': _selectedMedicines,
            'waktu': _tanggalController.text,
            'dokter': _namaController.text,
            'rujukan': _rujukanController.text,
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
                      MaterialPageRoute(
                          builder: (context) => BotNavBarDokter(
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
              "Resep Pasien",
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
                          "Nama Pasien",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: biruNavy,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _pasienController,
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama pasien tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Obat",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: biruNavy,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                        MultiSelectDialogField<String>(
                          items: _medicine.map((medicine) {
                            return MultiSelectItem<String>(
                              medicine['nama']!,
                              medicine['nama']!,
                            );
                          }).toList(),
                          title: Text("Pilih Obat"),
                          selectedColor: biruNavy,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            border: Border.all(
                              color: biruNavy,
                              width: 2,
                            ),
                          ),
                          buttonIcon: Icon(
                            Icons.arrow_drop_down,
                            color: biruNavy,
                          ),
                          buttonText: Text(
                            "Pilih Obat",
                            style: TextStyle(
                              color: biruNavy,
                              fontSize: 16,
                            ),
                          ),
                          dialogHeight: _medicine.length <= 8
                              ? _medicine.length * 50.0
                              : 400.0,
                          onConfirm: (values) {
                            setState(() {
                              _selectedMedicines = values;
                            });
                          },
                          validator: (values) {
                            if (values == null || values.isEmpty) {
                              return 'Obat tidak boleh kosong';
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
                              return 'Dokter tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Rujukan",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: biruNavy,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _rujukanController,
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
                          // readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Rujukan tidak boleh kosong';
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
                                assignmedicine();
                              }
                            },
                            child: Text(
                              'SIMPAN',
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
