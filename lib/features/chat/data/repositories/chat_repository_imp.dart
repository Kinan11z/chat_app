import 'dart:io';

import 'package:chat_app/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

import '../../../auth/data/models/user_model.dart';

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
    required String roomId,
    required String? type,
    required UserModel userInfo,
  }) async {
    return await remoteDataSource.sendMessage(
      message: message,
      roomId: roomId,
      type: type,
      userInfo: userInfo,
    );
  }

  @override
  Future<void> sendImage({
    required String roomId,
    required File imageFile,
    required UserModel userInfo,
  }) async {
    return await remoteDataSource.sendImage(
      roomId: roomId,
      imageFile: imageFile,
      userInfo: userInfo,
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
