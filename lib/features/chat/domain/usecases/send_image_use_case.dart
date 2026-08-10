import 'dart:io';

import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

class SendImageUseCase {
  final ChatRepository repository;

  SendImageUseCase({required this.repository});

  Future<void> call({
    required String uid,
    required String roomId,
    required File fileImage,
  }) async {
    await repository.sendImage(
      roomId: roomId,
      uid: uid,
      imageFile: fileImage,
    );
  }
}
