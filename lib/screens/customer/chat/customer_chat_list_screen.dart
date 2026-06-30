import 'package:flutter/material.dart';

import '../../../../services/chat_service.dart';
import '../../../../widgets/chat/chat_tile.dart';
import 'customer_chat_room_screen.dart';

class CustomerChatListScreen extends StatefulWidget {

  const CustomerChatListScreen({super.key});

  @override
  State<CustomerChatListScreen> createState() =>
      _CustomerChatListScreenState();
}

class _CustomerChatListScreenState
    extends State<CustomerChatListScreen> {

  bool isLoading = true;

  List rooms = [];

  @override
  void initState() {
    super.initState();
    loadChats();
  }

  Future loadChats() async {

    rooms = await ChatService.instance.customerRooms();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(

        backgroundColor: Colors.white,

        foregroundColor: Colors.black,

        elevation: 0,

        title: const Text(
          "Chat Owner",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : rooms.isEmpty

              ? const Center(
                  child: Text(
                    "Belum ada percakapan",
                  ),
                )

              : RefreshIndicator(

                  onRefresh: loadChats,

                  child: ListView.builder(

                    itemCount: rooms.length,

                    itemBuilder: (context,index){

                      final room = rooms[index];

                      final owner = room["owner"];

                      return ChatTile(

                        name:
                            owner["full_name"] ??
                            "Owner",

                        photo:
                            owner["photo_url"],

                        lastMessage:
                            room["last_message"] ??
                            "Belum ada pesan",

                        lastTime:
                            room["last_message_time"] == null
                                ? null
                                : DateTime.parse(
                                    room["last_message_time"],
                                  ),

                        onTap: () {

                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder: (_)=>

                                  CustomerChatRoomScreen(

                                    roomId:
                                        room["id"],

                                    ownerName:
                                        owner["full_name"] ??
                                        "",

                                    ownerPhoto:
                                        owner["photo_url"],
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}