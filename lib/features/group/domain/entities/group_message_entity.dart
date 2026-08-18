class GroupMessageEntity {
  final String id;
  final String fromId;
  final String toId;
  final String message;
  final String type;
  final String createdAt;
  final String read;

  const GroupMessageEntity({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.read,
  });

  GroupMessageEntity copyWith({
    String? id,
    String? fromId,
    String? toId,
    String? message,
    String? type,
    String? createdAt,
    String? read,
  }) {
    return GroupMessageEntity(
      id: id ?? this.id,
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}
