class ChatGroupEntity {
  final String id;
  final String name;
  final String? image;
  final List<String> members;
  final List<String> admins;
  final String lastMessage;
  final String lastMessageTime;
  final String createdAt;

  ChatGroupEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.members,
    required this.admins,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
  });

  ChatGroupEntity copyWith({
    String? id,
    String? name,
    String? image,
    List<String>? members,
    List<String>? admins,
    String? lastMessage,
    String? lastMessageTime,
    String? createdAt,
  }) {
    return ChatGroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      members: members ?? this.members,
      admins: admins ?? this.admins,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
