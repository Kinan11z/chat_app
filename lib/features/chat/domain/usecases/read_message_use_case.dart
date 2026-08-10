import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

class ReadMessageUseCase {
  final ChatRepository repository;

  ReadMessageUseCase({required this.repository});

  Future<void> call({required String roomId, required String messageId}) async {
    await repository.readMessage(
      messageId: messageId,
      roomId: roomId,
    );
  }
}
