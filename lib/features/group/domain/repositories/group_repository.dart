import 'dart:io';

import '../../data/models/chat_group_model.dart';

abstract class GroupRepository {
  Future createGroup({required String name, required List members});
  Future sendGroupMessage({
    required String message,
    required ChatGroupModel groupInfo,
    required String? type,
  });
  Future<void> sendImage({
    required File imageFile,
    required ChatGroupModel groupInfo,
  });
  Future editGroup({
    required String groupId,
    required String name,
    required List members,
  });
  Future removeMember({
    required String memberId,
    required String groupId,
  });
  Future promoteMember({
    required String memberId,
    required String groupId,
  });
  Future removePromote({
    required String memberId,
    required String groupId,
  });
}
