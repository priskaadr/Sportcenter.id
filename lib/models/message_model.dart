class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "room_id": roomId,
      "sender_id": senderId,
      "message": message,
      "is_read": isRead,
      "created_at": createdAt.toIso8601String(),
    };
  }
}