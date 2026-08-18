import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../repositories/group_repository.dart';

class EditGroupParams {
  final String groupId;
  final String name;
  final List<String> members;

  EditGroupParams({
    required this.groupId,
    required this.name,
    required this.members,
  });
}

class EditGroupUseCase extends UseCase<void, EditGroupParams> {
  final GroupRepository repository;

  EditGroupUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(EditGroupParams params) async {
    return await repository.editGroup(
      groupId: params.groupId,
      name: params.name,
      members: params.members,
    );
  }
}
