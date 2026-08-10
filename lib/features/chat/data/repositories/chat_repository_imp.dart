import 'dart:io';

import 'package:chat_app/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImp extends ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImp({required this.remoteDataSource});
  @override
  Future<void> createChatRoom(String email) async {
    return await remoteDataSource.createRoom(email);
  }

  @override
  Future<void> sendMessage({
    required String message,
    required String uid,
    required String roomId,
    required String? type,
  }) async {
    return await remoteDataSource.sendMessage(
        message: message, uid: uid, roomId: roomId, type: type);
  }

  @override
  Future<void> sendImage({
    required String uid,
    required String roomId,
    required File imageFile,
  }) async {
    return await remoteDataSource.sendImage(
      uid: uid,
      roomId: roomId,
      imageFile: imageFile,
    );
  }

  @override
  Future<void> readMessage({
    required String roomId,
    required String messageId,
  }) async {
    return await remoteDataSource.readMessage(
      messageId: messageId,
      roomId: roomId,
    );
  }

  @override
  Future<void> deleteMessage(
      {required String roomId, required List<String> messageIds}) async {
    return await remoteDataSource.deleteMessage(
      roomId: roomId,
      messageIds: messageIds,
    );
  }
}
