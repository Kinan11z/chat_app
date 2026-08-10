import '../repositories/group_repository.dart';

class SendGroupMessageUseCase {
  final GroupRepository repository;

  SendGroupMessageUseCase({required this.repository});

  Future<void> call({
    required String message,
    required String groupId,
    required String? type,
  }) async {
    await repository.sendGroupMessage(
      message: message,
      groupId: groupId,
      type: type,
    );
  }
}
