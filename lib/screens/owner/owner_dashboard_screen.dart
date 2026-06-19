import 'package:flutter/material.dart';

import 'owner_home_screen.dart';
import 'owner_field_screen.dart';
import 'owner_schedule_screen.dart';
import 'owner_chat_screen.dart';
import 'owner_profile_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState
    extends State<OwnerDashboardScreen> {

  int currentIndex = 0;

  final List<Widget> pages = [
    const OwnerHomeScreen(),
    const OwnerFieldScreen(),
    const OwnerScheduleScreen(),
    const OwnerChatScreen(),
    const OwnerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        selectedItemColor:
            const Color(0xff001DFF),

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: "Lapangan",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Jadwal",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}