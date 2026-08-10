class ChatRoomEntity {
  String? id;
  List? members;
  String? lastMessage;
  String? lastMessageTime;
  String? createdAt;

  ChatRoomEntity({
    this.id,
    this.members,
    this.lastMessage,
    this.lastMessageTime,
    this.createdAt,
  });
}
