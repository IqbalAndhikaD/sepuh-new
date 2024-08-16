import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class riwayatUser extends StatefulWidget {
  final String token;

  // ignore: use_super_parameters
  const riwayatUser({Key? key, required this.token}) : super(key: key);

  @override
  State<riwayatUser> createState() => _riwayatUserState();
}

class _riwayatUserState extends State<riwayatUser> {
  bool _isLoading = true;
  String _riwayatKesehatan = '';

  @override
  void initState() {
    super.initState();
    _fetchRiwayatKesehatan();
  }

  Future<void> _fetchRiwayatKesehatan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://sepuh-api.vercel.app/user/pasien'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<Map<String, dynamic>> usersData =
            responseData['data'].cast<Map<String, dynamic>>();

        final currentUser = usersData.firstWhere(
          (user) => user['token'] == widget.token,
          orElse: () => {},
        );

        if (currentUser != null) {
          setState(() {
            _riwayatKesehatan = (currentUser['riwayat'] as List<dynamic>)
                .map((item) => item.toString())
                .join('\n');
            _isLoading = false;
          });
        } else {
          throw Exception('User not found');
        }
      } else {
        throw Exception('Failed to load riwayat kesehatan');
      }
    } catch (e) {
      print('Error fetching riwayat kesehatan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching riwayat kesehatan: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Kesehatan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
                _riwayatKesehatan,
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}
