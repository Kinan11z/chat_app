import 'dart:typed_data';

import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:chat_app/features/chat/domain/entities/chat_room_entity.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failure.dart';

class ChatRepositoryImp implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImp({required this.remoteDataSource});
  @override
  Future<Either<Failure, void>> createChatRoom({required String email}) async {
    try {
      await remoteDataSource.createRoom(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Create room failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String message,
    required String roomId,
    required String? type,
    required UserEntity userInfo,
  }) async {
    try {
      await remoteDataSource.sendMessage(
        message: message,
        roomId: roomId,
        type: type,
        userInfo: userInfo,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Send message failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendImage({
    required String roomId,
    required Uint8List imageFile,
    required String fileExtension,
    required UserEntity userInfo,
  }) async {
    try {
      await remoteDataSource.sendImage(
        roomId: roomId,
        imageFile: imageFile,
        fileExtension: fileExtension,
        userInfo: userInfo,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Send image failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> readMessage({
    required String roomId,
    required String messageId,
  }) async {
    try {
      await remoteDataSource.readMessage(
        messageId: messageId,
        roomId: roomId,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Read message failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(
      {required String roomId, required List<String> messageIds}) async {
    try {
      await remoteDataSource.deleteMessage(
        roomId: roomId,
        messageIds: messageIds,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Delete message failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<ChatRoomEntity>> getChats() {
    return remoteDataSource
        .getChats()
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<MessageEntity>> getMessages({required String roomId}) {
    return remoteDataSource.getMessages(roomId: roomId).map(
          (models) => models
              .map(
                (m) => m.toEntity(),
              )
              .toList(),
        );
  }

  @override
  Stream<List<UserEntity>> getUsers({required List<String> ids}) {
    return remoteDataSource.getUsers(ids: ids).map(
          (models) => models
              .map(
                (m) => m.toEntity(),
              )
              .toList(),
        );
  }
}
