class ChatRoomModel {
  String? id;
  List? members;
  String? lastMessage;
  String? lastMessageTime;
  String? createdAt;

  ChatRoomModel({
    this.id,
    this.members,
    this.lastMessage,
    this.lastMessageTime,
    this.createdAt,
  });

  factory ChatRoomModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChatRoomModel(
      id: json['id'] ?? '' as String?,
      members: json['members'] ?? [] as List?,
      lastMessage: json['last_message'] ?? '' as String?,
      lastMessageTime: json['last_message_time'] ?? '' as String?,
      createdAt: json['created_at'] ?? '' as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['members'] = members;
    data['last_message'] = lastMessage;
    data['last_message_time'] = lastMessageTime;
    data['created_at'] = createdAt;

    return data;
  }
}
