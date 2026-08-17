import 'dart:io';

import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

import '../../../auth/data/models/user_model.dart';

class SendImageUseCase {
  final ChatRepository repository;

  SendImageUseCase({required this.repository});

  Future<void> call({
    required String roomId,
    required File fileImage,
    required UserModel userInfo,
  }) async {
    await repository.sendImage(
        roomId: roomId, imageFile: fileImage, userInfo: userInfo);
  }
}
