import 'dart:typed_data';

import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/features/group/data/datasource/group_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/chat_group_entity.dart';
import '../../domain/entities/group_message_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../../../auth/domain/entities/user_entity.dart';

class GroupRepositoryImp implements GroupRepository {
  final GroupRemoteDataSource remoteDataSource;

  GroupRepositoryImp({required this.remoteDataSource});
  @override
  Future<Either<Failure, void>> createGroup({
    required String name,
    required List<String> members,
  }) async {
    try {
      await remoteDataSource.createGroup(
        name: name,
        members: members,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Create group failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendGroupMessage({
    required String message,
    required ChatGroupEntity groupInfo,
    required String? type,
  }) async {
    try {
      await remoteDataSource.sendGroupMessage(
        message: message,
        groupInfo: groupInfo,
        type: type,
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
    required ChatGroupEntity groupInfo,
    required Uint8List imageFile,
    required String fileExtension,
  }) async {
    try {
      await remoteDataSource.sendImage(
        imageFile: imageFile,
        groupInfo: groupInfo,
        fileExtension: fileExtension,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? AppStrings.sendImageFailed));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> editGroup(
      {required String groupId,
      required String name,
      required List<String> members}) async {
    try {
      await remoteDataSource.editGroup(
        groupId: groupId,
        name: name,
        members: members,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? AppStrings.editGroupFailed));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember(
      {required String memberId, required String groupId}) async {
    try {
      await remoteDataSource.removeMember(
        memberId: memberId,
        groupId: groupId,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? AppStrings.removeMemberFailed));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> promoteMember(
      {required String memberId, required String groupId}) async {
    try {
      await remoteDataSource.promoteMember(
        memberId: memberId,
        groupId: groupId,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? AppStrings.memberPromotedFailed));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removePromote(
      {required String memberId, required String groupId}) async {
    try {
      await remoteDataSource.removePromote(
        memberId: memberId,
        groupId: groupId,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? AppStrings.removePromoteFailed));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<ChatGroupEntity>> getGroups() {
    return remoteDataSource
        .getGroups()
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<GroupMessageEntity>> getGroupMessages({required String groupId}) {
    return remoteDataSource.getGroupMessages(groupId: groupId).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Stream<List<UserEntity>> getUsers({required List<String> ids}) {
    return remoteDataSource.getUsers(ids: ids).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }
}
