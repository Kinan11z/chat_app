import 'package:chat_app/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/group_repository.dart';

class PromoteMemberParams {
  final String groupId;
  final String memberId;

  PromoteMemberParams({
    required this.groupId,
    required this.memberId,
  });
}

class PromoteMemberUseCase extends UseCase<void, PromoteMemberParams> {
  final GroupRepository repository;

  PromoteMemberUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(PromoteMemberParams params) async {
    return await repository.promoteMember(
      groupId: params.groupId,
      memberId: params.memberId,
    );
  }
}
