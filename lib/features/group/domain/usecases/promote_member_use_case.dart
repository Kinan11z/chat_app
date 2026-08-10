import '../repositories/group_repository.dart';

class PromoteMemberUseCase {
  final GroupRepository repository;

  PromoteMemberUseCase({required this.repository});

  Future<void> call({
    required String groupId,
    required String memberId,
  }) async {
    await repository.promoteMember(
      groupId: groupId,
      memberId: memberId,
    );
  }
}
