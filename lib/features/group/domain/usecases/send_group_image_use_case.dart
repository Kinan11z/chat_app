import 'dart:io';

import '../../data/models/chat_group_model.dart';
import '../repositories/group_repository.dart';

class SendGroupImageUseCase {
  final GroupRepository repository;

  SendGroupImageUseCase({required this.repository});

  Future<void> call({
    required File imageFile,
    required ChatGroupModel groupInfo,
  }) async {
    await repository.sendImage(
      imageFile: imageFile,
      groupInfo: groupInfo,
    );
  }
}
