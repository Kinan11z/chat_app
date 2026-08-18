import 'package:chat_app/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/group_repository.dart';

class CreateGroupParams {
  final String name;
  final List<String> members;

  CreateGroupParams({
    required this.name,
    required this.members,
  });
}

class CreateGroupUseCase extends UseCase<void, CreateGroupParams> {
  final GroupRepository repository;

  CreateGroupUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(CreateGroupParams params) async {
    return await repository.createGroup(
      name: params.name,
      members: params.members,
    );
  }
}
