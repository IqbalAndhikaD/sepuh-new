import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sepuh/model/pasien.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../../../widget/color.dart';

class ListPasienScreen extends StatefulWidget {
  const ListPasienScreen({Key? key}) : super(key: key);

  @override
  State<ListPasienScreen> createState() => _ListPasienScreenState();
}

class _ListPasienScreenState extends State<ListPasienScreen> {
  List<Pasien> _pasien = [];
  List<Pasien> _filteredPasien = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPasien();
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
          _filteredPasien = _pasien;
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

  void _filterPasien(String query) {
    setState(() {
      _filteredPasien = _pasien
          .where((pasien) =>
              pasien.nama.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Pasien',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: biruNavy,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Pasien',
                hintText: 'Masukkan nama pasien',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: _filterPasien,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildPatientList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList() {
    return ListView.builder(
      itemCount: _filteredPasien.length,
      itemBuilder: (context, index) {
        final patient = _filteredPasien[index];
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
