import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

class DeleteMessageUseCase {
  final ChatRepository repository;

  DeleteMessageUseCase({required this.repository});

  Future<void> call(
      {required String roomId, required List<String> messageIds}) async {
    await repository.deleteMessage(
      messageIds: messageIds,
      roomId: roomId,
    );
  }
}
