import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {

  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(
        left: 12,
        bottom: 10,
      ),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: const SizedBox(
        width: 40,
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,
          children: [

            CircleAvatar(
              radius: 3,
            ),

            CircleAvatar(
              radius: 3,
            ),

            CircleAvatar(
              radius: 3,
            ),
          ],
        ),
      ),
    );
  }
}