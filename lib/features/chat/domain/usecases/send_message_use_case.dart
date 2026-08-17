import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

import '../../../auth/data/models/user_model.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase({required this.repository});

  Future<void> call({
    required String message,
    required String roomId,
    required String? type,
    required UserModel userInfo,
  }) async {
    await repository.sendMessage(
      message: message,
      roomId: roomId,
      type: type,
      userInfo: userInfo,
    );
  }
}
