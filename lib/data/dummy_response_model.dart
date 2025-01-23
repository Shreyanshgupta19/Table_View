
class ChatMessage {
  final int id;
  final String content;
  final int userId;
  final int roomId;
  final DateTime time;
  final String chatType;

  ChatMessage({
    required this.id,
    required this.content,
    required this.userId,
    required this.roomId,
    required this.time,
    required this.chatType,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      userId: json['user_id'],
      roomId: json['room_id'],
      time: DateTime.parse(json['time']),
      chatType: json['chat_type'],
    );
  }
}
