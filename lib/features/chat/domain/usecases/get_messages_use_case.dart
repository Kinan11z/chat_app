import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/usecases/usecase.dart';

class GetMessagesParams {
  final String roomId;

  GetMessagesParams({required this.roomId});
}

class GetMessagesStream
    extends StreamUseCase<List<MessageEntity>, GetMessagesParams> {
  final ChatRepository repository;

  GetMessagesStream({required this.repository});

  @override
  Stream<List<MessageEntity>> call(GetMessagesParams params) {
    return repository.getMessages(roomId: params.roomId);
  }
}
