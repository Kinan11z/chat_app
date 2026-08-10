import 'dart:io';

abstract class ChatRepository {
  Future<void> createChatRoom(String email);
  Future<void> sendMessage({
    required String message,
    required String uid,
    required String roomId,
    required String? type,
  });
  Future<void> sendImage({
    required String uid,
    required String roomId,
    required File imageFile,
  });
  Future<void> readMessage({
    required String roomId,
    required String messageId,
  });
  Future<void> deleteMessage({
    required String roomId,
    required List<String> messageIds,
  });
}
