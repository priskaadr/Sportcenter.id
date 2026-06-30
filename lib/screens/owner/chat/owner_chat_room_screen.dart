import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/chat_service.dart';
import '../../../widgets/chat/chat_bubble.dart';
import '../../../widgets/chat/chat_input.dart';

class OwnerChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String customerName;
  final String? customerPhoto;

  const OwnerChatRoomScreen({
    super.key,
    required this.roomId,
    required this.customerName,
    this.customerPhoto,
  });

  @override
  State<OwnerChatRoomScreen> createState() =>
      _OwnerChatRoomScreenState();
}

class _OwnerChatRoomScreenState
    extends State<OwnerChatRoomScreen> {

  final controller = TextEditingController();

  final supabase = Supabase.instance.client;

  List messages = [];

  RealtimeChannel? channel;

  @override
  void initState() {
    super.initState();

    loadMessages();

    listenRealtime();
  }

  Future loadMessages() async {

    messages =
        await ChatService.instance
            .getMessages(widget.roomId);

    if (mounted) {
      setState(() {});
    }
  }

  void listenRealtime() {

    channel = supabase.channel(
      "chat-${widget.roomId}",
    );

    channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: "public",
          table: "messages",
          callback: (payload) async {

            await loadMessages();

          },
        )
        .subscribe();
  }

  Future send() async {

    if (controller.text.trim().isEmpty) {
      return;
    }

    await ChatService.instance.sendMessage(
      roomId: widget.roomId,
      text: controller.text.trim(),
    );

    controller.clear();

    await loadMessages();
  }

  @override
  void dispose() {

    controller.dispose();

    if(channel!=null){
      supabase.removeChannel(channel!);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final myId =
        supabase.auth.currentUser!.id;

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(

        elevation: 0,

        backgroundColor: Colors.white,

        foregroundColor: Colors.black,

        title: Row(
          children: [

            CircleAvatar(

              backgroundImage:

                  widget.customerPhoto != null

                      ? NetworkImage(
                          widget.customerPhoto!,
                        )

                      : null,

              child:

                  widget.customerPhoto == null

                      ? const Icon(Icons.person)

                      : null,
            ),

            const SizedBox(width: 12),

            Expanded(

              child: Text(
                widget.customerName,
              ),
            )
          ],
        ),
      ),

      body: Column(

        children: [

          Expanded(

            child: ListView.builder(

              reverse: true,

              padding:
                  const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),

              itemCount: messages.length,

              itemBuilder: (context,index){

                final msg =
                    messages[
                        messages.length-1-index];

                return ChatBubble(

                  isMine:
                      msg["sender_id"]==myId,

                  message:
                      msg["message"],

                  time:
                      DateTime.parse(
                        msg["created_at"],
                      ),

                  isRead:
                      msg["is_read"]??false,
                );
              },
            ),
          ),

          ChatInput(

            controller: controller,

            onSend: send,
          )
        ],
      ),
    );
  }
}