import '../repositories/group_repository.dart';

class EditGroupUseCase {
  final GroupRepository repository;

  EditGroupUseCase({required this.repository});

  Future<void> call({
    required String groupId,
    required String name,
    required List<String> members,
  }) async {
    await repository.editGroup(
      groupId: groupId,
      name: name,
      members: members,
    );
  }
}
