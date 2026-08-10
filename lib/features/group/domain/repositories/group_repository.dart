abstract class GroupRepository {
  Future createGroup({required String name, required List members});
  Future sendGroupMessage({
    required String message,
    required String groupId,
    required String? type,
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
