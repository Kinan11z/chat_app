import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';

class CreateChatRoomParams {
  final String email;
  const CreateChatRoomParams({required this.email});
}

class ChatRoomUseCase extends UseCase<void, CreateChatRoomParams> {
  final ChatRepository repository;

  ChatRoomUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(CreateChatRoomParams params) async {
    return await repository.createChatRoom(email: params.email);
  }
}
