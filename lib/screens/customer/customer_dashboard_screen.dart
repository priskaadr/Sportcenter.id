import 'package:flutter/material.dart';

import 'customer_home_screen.dart';
import 'customer_booking_screen.dart';
import 'customer_chat_screen.dart';
import 'customer_favorite_screen.dart';
import 'customer_profile_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState
    extends State<CustomerDashboardScreen> {

  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = const [
      CustomerHomeScreen(),
      CustomerBookingScreen(),
      CustomerChatScreen(),
      CustomerFavoriteScreen(),
      CustomerProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: AnimatedSwitcher(

        duration: const Duration(milliseconds: 250),

        child: pages[currentIndex],
      ),

      bottomNavigationBar: NavigationBar(

        selectedIndex: currentIndex,

        height: 72,

        backgroundColor: Colors.white,

        indicatorColor:
            const Color(0xff001DFF).withOpacity(.12),

        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,

        destinations: const [

          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),

          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: "Booking",
          ),

          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat),
            label: "Chat",
          ),

          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: "Favorit",
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profil",
          ),
        ],

        onDestinationSelected: (index) {

          setState(() {

            currentIndex = index;

          });
        },
      ),
    );
  }
}