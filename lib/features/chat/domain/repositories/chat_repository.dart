import 'dart:typed_data';

import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/chat_room_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, void>> createChatRoom({required String email});
  Future<Either<Failure, void>> sendMessage({
    required String message,
    required String roomId,
    required String? type,
    required UserEntity userInfo,
  });
  Future<Either<Failure, void>> sendImage({
    required String roomId,
    required Uint8List imageFile,
    required String fileExtension,
    required UserEntity userInfo,
  });
  Future<Either<Failure, void>> readMessage({
    required String roomId,
    required String messageId,
  });
  Future<Either<Failure, void>> deleteMessage({
    required String roomId,
    required List<String> messageIds,
  });
  Stream<List<ChatRoomEntity>> getChats();
  Stream<List<MessageEntity>> getMessages({required String roomId});
  Stream<List<UserEntity>> getUsers({required List<String> ids});
}
