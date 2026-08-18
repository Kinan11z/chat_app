import 'package:chat_app/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/group_repository.dart';

class RemoveMemberParams {
  final String groupId;
  final String memberId;

  RemoveMemberParams({
    required this.groupId,
    required this.memberId,
  });
}

class RemoveMemberUseCase extends UseCase<void, RemoveMemberParams> {
  final GroupRepository repository;

  RemoveMemberUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(RemoveMemberParams params) async {
    return await repository.removeMember(
      groupId: params.groupId,
      memberId: params.memberId,
    );
  }
}
