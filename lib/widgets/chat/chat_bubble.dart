import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final bool isMine;
  final String message;
  final DateTime time;
  final bool isRead;

  const ChatBubble({
    super.key,
    required this.isMine,
    required this.message,
    required this.time,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 280,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isMine
              ? const Color(0xff0057FF)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                Radius.circular(isMine ? 18 : 0),
            bottomRight:
                Radius.circular(isMine ? 0 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: TextStyle(
                  color: isMine
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  DateFormat(
                    "HH:mm",
                  ).format(time),
                  style: TextStyle(
                    fontSize: 11,
                    color: isMine
                        ? Colors.white70
                        : Colors.grey,
                  ),
                ),

                if (isMine)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5),
                    child: Icon(
                      isRead
                          ? Icons.done_all
                          : Icons.done,
                      size: 15,
                      color: Colors.white70,
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}