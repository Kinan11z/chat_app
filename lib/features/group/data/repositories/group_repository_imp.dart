import 'dart:io';

import 'package:chat_app/features/group/data/datasource/group_remote_data_source.dart';

import '../../domain/repositories/group_repository.dart';
import '../models/chat_group_model.dart';

class GroupRepositoryImp extends GroupRepository {
  final GroupRemoteDataSource remoteDataSource;

  GroupRepositoryImp({required this.remoteDataSource});
  @override
  Future createGroup({
    required String name,
    required List<String> members,
  }) {
    return remoteDataSource.createGroup(
      name: name,
      members: members,
    );
  }

  @override
  Future sendGroupMessage({
    required String message,
    required ChatGroupModel groupInfo,
    required String? type,
  }) {
    return remoteDataSource.sendGroupMessage(
      message: message,
      groupInfo: groupInfo,
      type: type,
    );
  }

  @override
  Future sendImage({
    required File imageFile,
    required ChatGroupModel groupInfo,
  }) {
    return remoteDataSource.sendImage(
      imageFile: imageFile,
      groupInfo: groupInfo,
    );
  }

  @override
  Future editGroup(
      {required String groupId,
      required String name,
      required List<String> members}) {
    return remoteDataSource.editGroup(
      groupId: groupId,
      name: name,
      members: members,
    );
  }

  @override
  Future removeMember({required String memberId, required String groupId}) {
    return remoteDataSource.removeMember(
      memberId: memberId,
      groupId: groupId,
    );
  }

  @override
  Future promoteMember({required String memberId, required String groupId}) {
    return remoteDataSource.promoteMember(
      memberId: memberId,
      groupId: groupId,
    );
  }

  @override
  Future removePromote({required String memberId, required String groupId}) {
    return remoteDataSource.removePromote(
      memberId: memberId,
      groupId: groupId,
    );
  }
}
