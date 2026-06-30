class ChatRoomModel {
  final String id;
  final String bookingId;
  final String ownerId;
  final String customerId;
  final String? lastMessage;
  final String? lastSender;
  final DateTime? lastMessageTime;

  ChatRoomModel({
    required this.id,
    required this.bookingId,
    required this.ownerId,
    required this.customerId,
    this.lastMessage,
    this.lastSender,
    this.lastMessageTime,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'],
      bookingId: json['booking_id'],
      ownerId: json['owner_id'],
      customerId: json['customer_id'],
      lastMessage: json['last_message'],
      lastSender: json['last_sender'],
      lastMessageTime: json['last_message_time'] == null
          ? null
          : DateTime.parse(json['last_message_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "booking_id": bookingId,
      "owner_id": ownerId,
      "customer_id": customerId,
      "last_message": lastMessage,
      "last_sender": lastSender,
      "last_message_time": lastMessageTime?.toIso8601String(),
    };
  }
}