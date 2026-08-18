import 'package:chat_app/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/group_repository.dart';

class RemovePromoteParams {
  final String groupId;
  final String memberId;

  RemovePromoteParams({
    required this.groupId,
    required this.memberId,
  });
}

class RemovePromoteUseCase extends UseCase<void, RemovePromoteParams> {
  final GroupRepository repository;

  RemovePromoteUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(RemovePromoteParams params) async {
    return await repository.removePromote(
      groupId: params.groupId,
      memberId: params.memberId,
    );
  }
}
