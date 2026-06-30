import 'package:flutter/material.dart';

class CustomerChatScreen extends StatelessWidget {

  const CustomerChatScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(

      body: Center(

        child: Text(

          "Chat",

          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}