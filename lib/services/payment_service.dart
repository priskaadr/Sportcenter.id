import 'package:supabase_flutter/supabase_flutter.dart';

import 'chat_service.dart';

class PaymentService {
  PaymentService._();

  static final instance = PaymentService._();

  final supabase = Supabase.instance.client;

  Future<String> createBooking({
    required String customerId,
    required String ownerId,
    required String fieldId,
    required DateTime bookingDate,
    required String startTime,
    required String endTime,
    required int duration,
    required String note,
    required int totalPrice,
    required String paymentMethod,
    required String? paymentProof,
  }) async {

    //---------------------------------------
    // INSERT BOOKING
    //---------------------------------------

    final booking = await supabase
        .from("bookings")
        .insert({
          "customer_id": customerId,
          "field_id": fieldId,
          "booking_date":
              bookingDate.toIso8601String().split("T").first,
          "start_time": startTime,
          "end_time": endTime,
          "duration": duration,
          "note": note,
          "total_price": totalPrice,
          "status": "pending",
        })
        .select()
        .single();

    //---------------------------------------
    // INSERT PAYMENT
    //---------------------------------------

    await supabase.from("payments").insert({
      "booking_id": booking["id"],
      "amount": totalPrice,
      "payment_method": paymentMethod,
      "payment_status": "waiting",
      "payment_date": DateTime.now().toIso8601String(),
      "payment_proof": paymentProof,
    });

    //---------------------------------------
    // CREATE CHAT ROOM
    //---------------------------------------

    final roomId = await ChatService.instance.createRoom(
      bookingId: booking["id"],
      ownerId: ownerId,
      customerId: customerId,
    );

    return roomId;
  }
}