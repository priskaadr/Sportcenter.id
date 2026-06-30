import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatTile extends StatelessWidget {

  final String name;

  final String? photo;

  final String lastMessage;

  final DateTime? lastTime;

  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.photo,
    required this.lastMessage,
    required this.lastTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(

      onTap: onTap,

      leading: CircleAvatar(

        radius: 28,

        backgroundImage:

            photo != null && photo!.isNotEmpty

                ? NetworkImage(photo!)

                : null,

        child:

            photo == null || photo!.isEmpty

                ? const Icon(Icons.person)

                : null,
      ),

      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      trailing: lastTime == null

          ? null

          : Text(
              DateFormat(
                "HH:mm",
              ).format(lastTime!),
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
    );
  }
}