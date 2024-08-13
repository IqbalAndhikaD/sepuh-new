// ignore_for_file: file_names, unnecessary_import

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:sepuh/screen/user/screen/jadwalScreenUser.dart';
import 'package:sepuh/screen/user/screen/profileScreenUser.dart';
import '../screen/homeScreenUser.dart';
import '../../../widget/color.dart';
class botNavbarUser extends StatefulWidget {
  final int index;
  const botNavbarUser({super.key, required this.index});

  @override
  State<botNavbarUser> createState() => _botNavbarUserState();
}

class _botNavbarUserState extends State<botNavbarUser> {
  int _currentIndex = 0;

  final List<Widget> _navigationItem = [
    const Icon(Icons.home_rounded, size: 40, color: Colors.white,),
    // const Icon(Icons.schedule_rounded, size: 40, color: Colors.white,),
    const Icon(Icons.person, size: 40, color: Colors.white,),
  ];

  final List<Widget> _screens = [
    const HomeScreenUser(), 
    // const jadwalScreen(),
    const ProfileScreenUser() 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        backgroundColor: biruNavy,
        color: biruNavy, 
        items: _navigationItem,
        animationDuration: const Duration(microseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        index: _currentIndex,
      ),
    );
  }
}





