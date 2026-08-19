import 'package:chat_app/features/group/domain/entities/group_message_entity.dart';
import 'package:chat_app/features/group/domain/repositories/group_repository.dart';

import '../../../../core/usecases/usecase.dart';

class GetGroupMessagesParams {
  final String groupId;

  GetGroupMessagesParams({required this.groupId});
}

class GetGroupMessagesStream
    extends StreamUseCase<List<GroupMessageEntity>, GetGroupMessagesParams> {
  final GroupRepository repository;

  GetGroupMessagesStream({required this.repository});

  @override
  Stream<List<GroupMessageEntity>> call(GetGroupMessagesParams params) {
    return repository.getGroupMessages(groupId: params.groupId);
  }
}