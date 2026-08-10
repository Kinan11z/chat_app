import '../repositories/group_repository.dart';

class RemovePromoteUseCase {
  final GroupRepository repository;

  RemovePromoteUseCase({required this.repository});

  Future<void> call({
    required String groupId,
    required String memberId,
  }) async {
    await repository.removePromote(
      groupId: groupId,
      memberId: memberId,
    );
  }
}
