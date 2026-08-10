// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  String? id;
  String? name;
  String? email;
  String? imageUrl;
  String? createdAt;
  String? about;
  String? lastActivated;
  String? pushToken;
  bool? online;
  List<String>? myUsers;
  UserModel({
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

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      id: json['id'] ?? '' as String?,
      name: json['name'] ?? '' as String?,
      email: json['email'] ?? '' as String?,
      imageUrl: json['image_url'] ?? '' as String?,
      createdAt: json['created_at'] ?? '' as String?,
      about: json['about'] ?? '' as String?,
      lastActivated: json['last_activated'] ?? '' as String?,
      pushToken: json['push_token'] ?? '' as String?,
      online: json['online'] ?? false as bool?,
      myUsers: List<String>.from(json['my_users'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['image_url'] = imageUrl;
    data['created_at'] = createdAt;
    data['about'] = about;
    data['last_activated'] = lastActivated;
    data['push_token'] = pushToken;
    data['online'] = online;
    data['my_users'] = myUsers;
    return data;
  }
}
