import 'package:chat_app/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/chat_group_entity.dart';
import '../repositories/group_repository.dart';

class SendGroupMessageParams {
  final String message;
  final ChatGroupEntity groupInfo;
  final String? type;

  SendGroupMessageParams({
    required this.message,
    required this.groupInfo,
    this.type,
  });
}

class SendGroupMessageUseCase extends UseCase<void, SendGroupMessageParams> {
  final GroupRepository repository;

  SendGroupMessageUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(SendGroupMessageParams params) async {
    return await repository.sendGroupMessage(
      message: params.message,
      groupInfo: params.groupInfo,
      type: params.type,
    );
  }
}
