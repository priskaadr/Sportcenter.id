import 'package:flutter/material.dart';

import '../../../../services/chat_service.dart';
import '../../../../widgets/chat/chat_tile.dart';
import 'owner_chat_room_screen.dart';

class OwnerChatListScreen extends StatefulWidget {
  const OwnerChatListScreen({super.key});

  @override
  State<OwnerChatListScreen> createState() =>
      _OwnerChatListScreenState();
}

class _OwnerChatListScreenState
    extends State<OwnerChatListScreen> {

  bool isLoading = true;

  List rooms = [];

  @override
  void initState() {
    super.initState();
    loadChats();
  }

  Future loadChats() async {

    rooms = await ChatService.instance.ownerRooms();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(

        elevation: 0,

        backgroundColor: Colors.white,

        foregroundColor: Colors.black,

        title: const Text(
          "Pesan Customer",
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
                    "Belum ada chat",
                  ),
                )

              : RefreshIndicator(

                  onRefresh: loadChats,

                  child: ListView.builder(

                    itemCount: rooms.length,

                    itemBuilder: (context,index){

                      final room = rooms[index];

                      final customer = room["customer"];

                      return ChatTile(

                        name:
                            customer["full_name"] ??
                            "Customer",

                        photo:
                            customer["photo_url"],

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

                                  OwnerChatRoomScreen(

                                    roomId:
                                        room["id"],

                                    customerName:
                                        customer["full_name"] ??
                                        "",

                                    customerPhoto:
                                        customer["photo_url"],
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