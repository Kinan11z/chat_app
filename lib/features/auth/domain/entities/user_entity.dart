class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  final String? createdAt;
  final String? about;
  final String? lastActivated;
  final String? pushToken;
  final bool online;
  final List<String> myUsers;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    this.createdAt,
    this.about,
    this.lastActivated,
    this.pushToken,
    required this.online,
    required this.myUsers,
  });
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    String? about,
    String? createdAt,
    String? lastActivated,
    String? pushToken,
    bool? online,
    List<String>? myUsers,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      about: about ?? this.about,
      createdAt: createdAt ?? this.createdAt,
      lastActivated: lastActivated ?? this.lastActivated,
      pushToken: pushToken ?? this.pushToken,
      online: online ?? this.online,
      myUsers: myUsers ?? this.myUsers,
    );
  }
}
