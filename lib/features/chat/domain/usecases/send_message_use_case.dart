import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';

class SendChatMessageParams {
  final String message;
  final String roomId;
  final String? type;
  final UserEntity userInfo;

  const SendChatMessageParams({
    required this.message,
    required this.roomId,
    required this.type,
    required this.userInfo,
  });
}

class SendMessageUseCase extends UseCase<void, SendChatMessageParams> {
  final ChatRepository repository;

  SendMessageUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(SendChatMessageParams params) async {
    return await repository.sendMessage(
      message: params.message,
      roomId: params.roomId,
      type: params.type,
      userInfo: params.userInfo,
    );
  }
}
