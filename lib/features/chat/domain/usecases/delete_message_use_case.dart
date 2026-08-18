import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';

class DeleteChatMessageParams {
  final String roomId;
  final List<String> messageIds;
  const DeleteChatMessageParams({
    required this.roomId,
    required this.messageIds,
  });
}

class DeleteMessageUseCase extends UseCase<void, DeleteChatMessageParams> {
  final ChatRepository repository;

  DeleteMessageUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteChatMessageParams params) async {
    return await repository.deleteMessage(
      messageIds: params.messageIds,
      roomId: params.roomId,
    );
  }
}
