import 'dart:io';

import '../../../auth/data/models/user_model.dart';

abstract class ChatRepository {
  Future<void> createChatRoom(String email);
  Future<void> sendMessage({
    required String message,
    required String roomId,
    required String? type,
    required UserModel userInfo,
  });
  Future<void> sendImage({
    required String roomId,
    required File imageFile,
    required UserModel userInfo,
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
