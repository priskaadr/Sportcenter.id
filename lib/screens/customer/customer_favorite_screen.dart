import 'package:flutter/material.dart';

class CustomerFavoriteScreen extends StatelessWidget {

  const CustomerFavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(

      body: Center(

        child: Text(

          "Favorite",

          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}