import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase({required this.repository});

  Future<void> call({
    required String message,
    required String uid,
    required String roomId,
    required String? type,
  }) async {
    await repository.sendMessage(
      message: message,
      roomId: roomId,
      uid: uid,
      type: type,
    );
  }
}
