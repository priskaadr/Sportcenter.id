import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/chat_service.dart';
import '../../../widgets/chat/chat_bubble.dart';
import '../../../widgets/chat/chat_input.dart';

class CustomerChatRoomScreen extends StatefulWidget {

  final String roomId;

  final String ownerName;

  final String? ownerPhoto;

  const CustomerChatRoomScreen({
    super.key,
    required this.roomId,
    required this.ownerName,
    this.ownerPhoto,
  });

  @override
  State<CustomerChatRoomScreen> createState() =>
      _CustomerChatRoomScreenState();
}

class _CustomerChatRoomScreenState
    extends State<CustomerChatRoomScreen> {

  final controller = TextEditingController();

  final supabase = Supabase.instance.client;

  List messages=[];

  RealtimeChannel? channel;

  @override
  void initState(){

    super.initState();

    loadMessages();

    realtime();
  }

  Future loadMessages() async{

    messages=await ChatService.instance
        .getMessages(widget.roomId);

    if(mounted){
      setState(() {});
    }
  }

  void realtime(){

    channel=supabase.channel(
      "chat-${widget.roomId}",
    );

    channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: "public",
          table: "messages",
          callback: (_) async{

            await loadMessages();

          },
        )
        .subscribe();
  }

  Future send() async{

    if(controller.text.trim().isEmpty){
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
  void dispose(){

    controller.dispose();

    if(channel!=null){
      supabase.removeChannel(channel!);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context){

    final myId=
        supabase.auth.currentUser!.id;

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(

        elevation:0,

        backgroundColor: Colors.white,

        foregroundColor: Colors.black,

        title: Row(

          children:[

            CircleAvatar(

              backgroundImage:

                  widget.ownerPhoto!=null

                      ?NetworkImage(
                        widget.ownerPhoto!,
                      )

                      :null,

              child:

                  widget.ownerPhoto==null

                      ?const Icon(Icons.person)

                      :null,
            ),

            const SizedBox(width:12),

            Expanded(
              child: Text(
                widget.ownerName,
              ),
            )
          ],
        ),
      ),

      body: Column(

        children:[

          Expanded(

            child: ListView.builder(

              reverse:true,

              itemCount:messages.length,

              itemBuilder:(context,index){

                final msg=
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

            controller:controller,

            onSend:send,
          )
        ],
      ),
    );
  }
}