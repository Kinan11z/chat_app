import 'package:chat_app/features/group/domain/entities/chat_group_entity.dart';
import 'package:chat_app/features/group/domain/repositories/group_repository.dart';

import '../../../../core/usecases/usecase.dart';

class GetGroupsStream extends StreamUseCase<List<ChatGroupEntity>, NoParams> {
  final GroupRepository repository;

  GetGroupsStream({required this.repository});

  @override
  Stream<List<ChatGroupEntity>> call(NoParams params) {
    return repository.getGroups();
  }
}