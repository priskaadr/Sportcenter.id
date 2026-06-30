import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {

  ChatService._();

  static final instance = ChatService._();

  final supabase = Supabase.instance.client;

  Future<List> ownerRooms() async {

    final owner =
        supabase.auth.currentUser!.id;

    return await supabase

        .from("chat_rooms")

        .select("""

          *,

          customer:profiles!chat_rooms_customer_id_fkey(*)

        """)

        .eq(
          "owner_id",
          owner,
        )

        .order(
          "last_message_time",
          ascending: false,
        );
  }

  Future<List> customerRooms() async {

    final customer =
        supabase.auth.currentUser!.id;

    return await supabase

        .from("chat_rooms")

        .select("""

          *,

          owner:profiles!chat_rooms_owner_id_fkey(*)

        """)

        .eq(
          "customer_id",
          customer,
        )

        .order(
          "last_message_time",
          ascending: false,
        );
  }

  Future<List> getMessages(
      String roomId) async {

    return await supabase

        .from("messages")

        .select()

        .eq(
          "room_id",
          roomId,
        )

        .order(
          "created_at",
        );
  }

  Future sendMessage({

    required String roomId,

    required String text,

  }) async {

    final sender =
        supabase.auth.currentUser!.id;

    await supabase

        .from("messages")

        .insert({

          "room_id": roomId,

          "sender_id": sender,

          "message": text,

        });

    await supabase

        .from("chat_rooms")

        .update({

          "last_message": text,

          "last_message_time":
              DateTime.now().toIso8601String(),

        })

        .eq(
          "id",
          roomId,
        );
  }

  Future createRoom({

    required String bookingId,

    required String ownerId,

    required String customerId,

  }) async {

    final room =
        await supabase

            .from("chat_rooms")

            .select()

            .eq(
              "booking_id",
              bookingId,
            )

            .maybeSingle();

    if (room != null) {

      return room["id"];
    }

    final data =
        await supabase

            .from("chat_rooms")

            .insert({

              "booking_id": bookingId,

              "owner_id": ownerId,

              "customer_id": customerId,

            })

            .select()

            .single();

    return data["id"];
  }

  Future readMessages(
      String roomId) async {

    final me =
        supabase.auth.currentUser!.id;

    await supabase

        .from("messages")

        .update({

          "is_read": true,

        })

        .eq(
          "room_id",
          roomId,
        )

        .neq(
          "sender_id",
          me,
        );
  }
}