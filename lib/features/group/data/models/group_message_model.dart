// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../domain/entities/group_message_entity.dart';

class GroupMessageModel {
  String? id;
  String? fromId;
  String? toId;
  String? message;
  String? type;
  String? createdAt;
  String? read;
  GroupMessageModel({
    this.id,
    this.fromId,
    this.toId,
    this.message,
    this.type,
    this.createdAt,
    this.read,
  });

  factory GroupMessageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroupMessageModel(
      id: json['id'] ?? '' as String?,
      toId: json['to_id'] ?? '' as String?,
      fromId: json['from_id'] ?? '' as String?,
      message: json['message'] ?? '' as String?,
      type: json['type'] ?? '' as String?,
      read: json['read'] ?? '' as String?,
      createdAt: json['created_at'] ?? '' as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['to_id'] = toId;
    data['from_id'] = fromId;
    data['message'] = message;
    data['type'] = type;
    data['read'] = read;
    data['created_at'] = createdAt;
    return data;
  }

  GroupMessageEntity toEntity() {
    return GroupMessageEntity(
      id: id ?? '',
      fromId: fromId ?? '',
      toId: toId ?? '',
      message: message ?? '',
      type: type ?? '',
      createdAt: createdAt ?? '',
      read: read ?? '',
    );
  }
}
