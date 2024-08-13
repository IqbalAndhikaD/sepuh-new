// ignore_for_file: file_names, camel_case_types

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sepuh/widget/color.dart';
import 'package:http/http.dart' as http;
import 'signInScreenUser.dart';

class signUpScreenUser extends StatelessWidget {
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    final response = await http.post(
      Uri.parse('https://sepuh-api.vercel.app/user/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nama': _namaController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 201 && jsonData['status'] == 201) {
      print('Registration successful');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => signInScreenUser()),
      );
    } else {
      print('${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff225374), Color(0xff28a09e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(3.14 / 6),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 8 + 156,
            left: MediaQuery.of(context).size.width / 12,
            right: MediaQuery.of(context).size.width / 12,
            child: Container(
              width: MediaQuery.of(context).size.width / 1.4,
              height: MediaQuery.of(context).size.height / 1.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 7.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => signInScreenUser()),
                              );
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            )),
                        TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xff225374),
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    TextField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        hintText: 'Nama',
                        prefixIcon: const Icon(Icons.account_circle),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      controller:
                          _usernameController, // Changed from _confirmPasswordController
                      decoration: InputDecoration(
                        hintText: 'Username',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: const Icon(Icons.email_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.password_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 2.0,
                          ),
                        ),
                        //obscureText: true,
                      ),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(320, 48),
                        backgroundColor: gbutton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onPressed: () async {
                        await _register(context);
                      },
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 34,
            right: 34,
            height: MediaQuery.of(context).size.height / 3.5,
            child: Container(
              width: MediaQuery.of(context).size.width / 1,
              height: MediaQuery.of(context).size.height / 80,
              decoration: BoxDecoration(
                color: const Color(0xff225374),
                borderRadius: BorderRadius.circular(30.0),
                image: const DecorationImage(
                  image: AssetImage('assets/logoLogin.png'),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
