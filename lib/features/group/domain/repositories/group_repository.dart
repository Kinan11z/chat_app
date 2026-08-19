import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/chat_group_entity.dart';
import '../entities/group_message_entity.dart';

abstract class GroupRepository {
  Future<Either<Failure, void>> createGroup(
      {required String name, required List<String> members});
  Future sendGroupMessage({
    required String message,
    required ChatGroupEntity groupInfo,
    required String? type,
  });
  Future<Either<Failure, void>> sendImage({
    required Uint8List imageFile,
    required String fileExtension,
    required ChatGroupEntity groupInfo,
  });
  Future<Either<Failure, void>> editGroup({
    required String groupId,
    required String name,
    required List<String> members,
  });
  Future<Either<Failure, void>> removeMember({
    required String memberId,
    required String groupId,
  });
  Future<Either<Failure, void>> promoteMember({
    required String memberId,
    required String groupId,
  });
  Future<Either<Failure, void>> removePromote({
    required String memberId,
    required String groupId,
  });
  Stream<List<ChatGroupEntity>> getGroups();
  Stream<List<GroupMessageEntity>> getGroupMessages({required String groupId});
  Stream<List<UserEntity>> getUsers({required List<String> ids});
}
