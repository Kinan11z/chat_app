class UserEntity {
  final String? id;
  final String? name;
  final String? email;
  final String? imageUrl;
  final String? createdAt;
  final String? about;
  final String? lastActivated;
  final String? pushToken;
  final bool? online;
  final List<String>? myUsers;

  const UserEntity({
    this.id,
    this.name,
    this.email,
    this.imageUrl,
    this.createdAt,
    this.about,
    this.lastActivated,
    this.pushToken,
    this.online,
    this.myUsers,
  });
}
