// ignore_for_file: file_names, camel_case_types, unused_field, unused_local_variable, use_key_in_widget_constructors, no_leading_underscores_for_local_identifiers, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:sepuh/screen/dokter/widget/botNavbarDokter.dart';
import 'package:http/http.dart' as http;
import 'package:sepuh/widget/pickRole.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sepuh/widget/color.dart';

class signInScreenDokter extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Future<void> _login() async {
      final response = await http.post(
        Uri.parse('https://sepuh-api.vercel.app/user/login/dokter'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 200) {
        final token = jsonData['data'];
        print('Registration successful: ${response.body}');
        // Save token to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BotNavBarDokter(index: 0,)),
        );
      } else {
        print('SignIn failed: ${response.body}');
      }
    }

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
            top: MediaQuery.of(context).size.height / 5,
            left: MediaQuery.of(context).size.width / 12,
            right: MediaQuery.of(context).size.width / 12,
            child: Container(
              width: MediaQuery.of(context).size.width / 1.4,
              height: MediaQuery.of(context).size.height / 1.3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () {
                              //login
                            },
                            child: const Text(
                              'Sign In',
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
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
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
                      height: 30.0,
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
                      height: 5.0,
                    ),
                    const Text(
                      'Forgot your password?',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color.fromARGB(255, 29, 90, 101),
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(
                      height: 35.0,
                    ),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(320, 48),
                        backgroundColor: gbutton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
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
              child: Padding(
                padding: const EdgeInsets.only(right: 260, bottom: 160),
                child: Positioned(
                  
                  child: TextButton(
                    child: const Text('Back', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => pickRole()),
                      );
                    },
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
