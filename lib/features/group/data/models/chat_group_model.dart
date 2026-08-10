class ChatGroupModel {
  String? id;
  String? name;
  String? image;
  List? members;
  List? admins;
  String? lastMessage;
  String? lastMessageTime;
  String? createdAt;

  ChatGroupModel({
    this.id,
    this.name,
    this.image,
    this.members,
    this.admins,
    this.lastMessage,
    this.lastMessageTime,
    this.createdAt,
  });

  factory ChatGroupModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChatGroupModel(
      id: json['id'] ?? '' as String?,
      name: json['name'] ?? '' as String?,
      image: json['image'] ?? '' as String?,
      members: json['members'] ?? [] as List?,
      admins: json['admins_id'] ?? [] as List?,
      lastMessage: json['last_message'] ?? '' as String?,
      lastMessageTime: json['last_message_time'] ?? '' as String?,
      createdAt: json['created_at'] ?? '' as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['members'] = members;
    data['admins_id'] = admins;
    data['last_message'] = lastMessage;
    data['last_message_time'] = lastMessageTime;
    data['created_at'] = createdAt;

    return data;
  }
}
