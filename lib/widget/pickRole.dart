import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sepuh/screen/dokter/authDokter/signInScreenDokter.dart';
import 'package:sepuh/screen/user/authUser/signInScreenUser.dart';
import 'package:sepuh/screen/user/authUser/signUpScreenUser.dart';

import 'color.dart';
import 'onBoarding.dart';

class pickRole extends StatefulWidget {
  @override
  _pickRoleState createState() => _pickRoleState();
}

class _pickRoleState extends State<pickRole> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [biruNavy, biruToska],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Positioned(
        //   top: 40,
        //   left: 20,
        //   child: IconButton(
        //     icon: Icon(Icons.arrow_back, color: Colors.white),
        //     onPressed: () {
        //       Navigator.pushReplacement(
        //         context,
        //         MaterialPageRoute(builder: (context) => Onboarding()),
        //       );
        //     },
        //   ),
        // ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pilih Role Untuk Login ',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 40),

              // Dokter Button
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey, width: 1),
                        color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Image.asset('assets/dokterr.png',
                          width: 150, height: 150),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gbutton,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => signInScreenDokter()),
                      );
                    },
                    child: Text(
                      'Login Sebagai Dokter',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Container(
                height: 2,
                width: 280,
                color: Colors.white,
              ),
              SizedBox(height: 40),
              // Pasien Button
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey, width: 1),
                        color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Image.asset('assets/pasien.png',
                          width: 150, height: 150),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gbutton,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => signInScreenUser()),
                      );
                    },
                    child: Text(
                      'Login Sebagai Pasien',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ]),
    );
  }
}
