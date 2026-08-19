import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/group/domain/repositories/group_repository.dart';

import '../../../../core/usecases/usecase.dart';

class GetUsersParams {
  final List<String> ids;

  GetUsersParams({required this.ids});
}

class GetGroupUsersStream
    extends StreamUseCase<List<UserEntity>, GetUsersParams> {
  final GroupRepository repository;

  GetGroupUsersStream({required this.repository});

  @override
  Stream<List<UserEntity>> call(GetUsersParams params) {
    return repository.getUsers(ids: params.ids);
  }
}
