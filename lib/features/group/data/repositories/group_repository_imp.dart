import 'package:chat_app/features/group/data/datasource/group_remote_data_source.dart';

import '../../domain/repositories/group_repository.dart';

class GroupRepositoryImp extends GroupRepository {
  final GroupRemoteDataSource remoteDataSource;

  GroupRepositoryImp({required this.remoteDataSource});
  @override
  Future createGroup({
    required String name,
    required List members,
  }) {
    return remoteDataSource.createGroup(
      name: name,
      members: members,
    );
  }

  @override
  Future sendGroupMessage({
    required String message,
    required String groupId,
    required String? type,
  }) {
    return remoteDataSource.sendGroupMessage(
      message: message,
      groupId: groupId,
      type: type,
    );
  }

  @override
  Future editGroup(
      {required String groupId, required String name, required List members}) {
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
