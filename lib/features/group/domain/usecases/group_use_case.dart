import '../repositories/group_repository.dart';

class GroupUseCase {
  final GroupRepository repository;

  GroupUseCase({required this.repository});

  Future<void> call({required String name, required List members}) async {
    await repository.createGroup(name: name, members: members);
  }
}
