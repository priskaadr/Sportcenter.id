import 'package:flutter/material.dart';

class CustomerProfileScreen extends StatelessWidget {

  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(

      body: Center(

        child: Text(

          "Profile",

          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}