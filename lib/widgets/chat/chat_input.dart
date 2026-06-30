import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {

  final TextEditingController controller;

  final VoidCallback onSend;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: const BoxDecoration(
          color: Colors.white,
        ),

        child: Row(
          children: [

            Expanded(
              child: TextField(
                controller: controller,

                decoration: InputDecoration(

                  hintText: "Tulis pesan...",

                  filled: true,

                  fillColor: Colors.grey.shade100,

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),

                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            CircleAvatar(

              radius: 26,

              backgroundColor:
                  const Color(0xff0057FF),

              child: IconButton(

                onPressed: onSend,

                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}