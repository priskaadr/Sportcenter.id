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

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = const [
      OwnerHomeScreen(),
      OwnerFieldScreen(),
      OwnerScheduleScreen(),
      OwnerChatScreen(),
      OwnerProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: currentIndex,

        type: BottomNavigationBarType.fixed,

        selectedItemColor: const Color(0xff001DFF),

        unselectedItemColor: Colors.grey,

        selectedFontSize: 12,

        unselectedFontSize: 12,

        elevation: 8,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Icon(Icons.home),
            label: "Beranda",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer_outlined),
            activeIcon: Icon(Icons.sports_soccer),
            label: "Lapangan",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: "Jadwal",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat),
            label: "Chat",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}