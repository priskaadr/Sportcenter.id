import 'package:flutter/material.dart';

class CustomerBookingScreen extends StatelessWidget {

  const CustomerBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(

      body: Center(

        child: Text(

          "Booking",

          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}