import '../repositories/group_repository.dart';

class RemoveMemberUseCase {
  final GroupRepository repository;

  RemoveMemberUseCase({required this.repository});

  Future<void> call({required String memberId, required String groupId}) async {
    await repository.removeMember(memberId: memberId, groupId: groupId);
  }
}
