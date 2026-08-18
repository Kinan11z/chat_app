import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';

class ReadChatMessageParams {
  final String roomId;
  final String messageId;
  const ReadChatMessageParams({
    required this.roomId,
    required this.messageId,
  });
}

class ReadMessageUseCase extends UseCase<void, ReadChatMessageParams> {
  final ChatRepository repository;

  ReadMessageUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(ReadChatMessageParams params) async {
    return await repository.readMessage(
      messageId: params.messageId,
      roomId: params.roomId,
    );
  }
}
