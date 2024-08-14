// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sepuh/screen/dokter/authDokter/signInScreenDokter.dart';
import 'package:sepuh/widget/color.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class ProfileScreenDokter extends StatefulWidget {
  const ProfileScreenDokter({super.key});

  @override
  _ProfileScreenDokterState createState() => _ProfileScreenDokterState();
}

class _ProfileScreenDokterState extends State<ProfileScreenDokter> {
  bool _isLoading = true;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _addressController;
  late TextEditingController _spesialisasiController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _ageController = TextEditingController();
    _addressController = TextEditingController();
    _spesialisasiController = TextEditingController();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _spesialisasiController.dispose();
    super.dispose();
  }

Future<void> _fetchUserData() async {
  setState(() {
    _isLoading = true;
  });

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('https://sepuh-api.vercel.app/user/dokter'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> doctorsData = responseData['data'];
      
      // Find the doctor with the matching token
      final currentDoctor = doctorsData.firstWhere(
        (doctor) => doctor['token'] == token,
        orElse: () => null,
      );

      if (currentDoctor != null) {
        setState(() {
          _nameController.text = currentDoctor['nama'] ?? '';
          _emailController.text = currentDoctor['email'] ?? '';
          _ageController.text = currentDoctor['usia']?.toString() ?? '';
          _addressController.text = currentDoctor['alamat'] ?? '';
          _spesialisasiController.text = currentDoctor['spesialisasi'] ?? '';
          _isLoading = false;
        });
        if (kDebugMode) {
          print("Data fetched successfully");
        }
      } else {
        throw Exception('Doctor not found');
      }
    } else {
      // Handle API call failure
      if (kDebugMode) {
        print('Failed to load user data. Status code: ${response.statusCode}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user data')),
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching user data: $e');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching user data: $e')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _showEditDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Nama",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    hintText: "Usia",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: "Alamat",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _spesialisasiController,
                  decoration: InputDecoration(
                    hintText: "Spesialisasi",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Update data di sini
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final token = prefs.getString('token');

                        if (token != null) {
                          Map<String, dynamic> decodedToken =
                              Jwt.parseJwt(token);
                          final userId = decodedToken['_id'];
                          if (kDebugMode) {
                            print(userId);
                          }
                          final dokterId = decodedToken[
                              '_id']; // assume this is the dokter ID

                          // Update user data
                          final urlUser =
                              'https://sepuh-api.vercel.app/user/$userId';
                          final headersUser = {
                            'Authorization': 'Bearer $token',
                            'Content-Type': 'application/json',
                          };
                          final bodyUser = jsonEncode({
                            'nama': _nameController.text,
                            'email': _emailController.text,
                            'usia': _ageController.text,
                            'alamat': _addressController.text,
                            'spesialisasi': _spesialisasiController.text,
                          });
                          if (kDebugMode) {
                            print("disini bodyuser : $bodyUser");
                          }
                          final responseUser = await http.put(
                              Uri.parse(urlUser),
                              headers: headersUser,
                              body: bodyUser);

                          if (responseUser.statusCode == 200) {
                            // print(responseUser.body);
                            //print('User data updated successfully');
                          } else {
                            if (kDebugMode) {
                              print(
                                  'Error updating user data: ${responseUser.statusCode}');
                            }
                          }

                          // Update spesialisasi data
                          final urldokter =
                              'https://sepuh-api.vercel.app/dokter/$dokterId';
                          final headersdokter = {
                            'Authorization': 'Bearer $token',
                            'Content-Type': 'application/json',
                          };
                          final bodydokter = jsonEncode({
                            'riwayat': _spesialisasiController.text,
                          });

                          final responsedokter = await http.put(
                              Uri.parse(urldokter),
                              headers: headersdokter,
                              body: bodydokter);

                          if (responsedokter.statusCode == 200) {
                            if (kDebugMode) {
                              print(responsedokter.body);
                            }
                            //print('Riwayat updated successfully');
                            Navigator.of(context).pop();
                          } else {
                            if (kDebugMode) {
                              print(
                                  'Error updating spesialisasi: ${responsedokter.statusCode}');
                            }
                          }
                        } else {
                          if (kDebugMode) {
                            print('Token not found');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gbutton,
                        minimumSize: const Size(100, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Save',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        );
      },
    );
  }

  Future<void> _logout() async {
    // Munculin custom logout dialog
    bool? confirmLogout = await showCustomLogoutDialog(context);

    // kalau user mau logout, ini logicnya yg nyambung ke api
    if (confirmLogout == true) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => signInScreenDokter()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error during logout: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during logout: $e')),
        );
      }
    }
  }

  Future<bool?> showCustomLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Apakah anda yakin ingin Logout?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE76F51),
                  minimumSize: const Size(100, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    const Text('TIDAK', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A9D8F),
                  minimumSize: const Size(100, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('YA', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF225374), Color(0xFF28A09E)],
                stops: [0.0, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.grey[300],
                                      child: ClipOval(
                                        child: Image.asset(
                                          "assets/doctor.png",
                                          width: 120.0,
                                          height: 120.0,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _nameController.text.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          'Dokter',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildTextField('Nama:', _nameController,
                                    readOnly: true),
                                const SizedBox(height: 10),
                                _buildTextField('Email:', _emailController,
                                    readOnly: true),
                                const SizedBox(height: 10),
                                _buildTextField('Umur:', _ageController,
                                    readOnly: true),
                                const SizedBox(height: 10),
                                _buildTextField('Alamat:', _addressController,
                                    readOnly: true),
                                const SizedBox(height: 10),
                                _buildTextField(
                                    'Spesialisasi:', _spesialisasiController,
                                    readOnly: true),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    width: 133,
                                    height: 34,
                                    child: ElevatedButton(
                                      onPressed: _showEditDialog,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 323,
                    height: 39,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7603F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          obscureText: obscureText,
          readOnly: readOnly,
          style: TextStyle(color: readOnly ? Colors.black : Colors.black),
        ),
      ],
    );
  }
}
