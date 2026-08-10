import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

class ChatRoomUseCase {
  final ChatRepository repository;

  ChatRoomUseCase({required this.repository});

  Future<void> call(String email) async {
    await repository.createChatRoom(email);
  }
}
