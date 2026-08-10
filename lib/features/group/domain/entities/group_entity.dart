class GroupEntity {
  final String? id;
  final String? name;
  final String? image;
  final List? members;
  final List? admins;
  final String? lastMessage;
  final String? lastMessageTime;
  final String? createdAt;

  GroupEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.members,
    required this.admins,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
  });
}
