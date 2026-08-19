import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/usecases/usecase.dart';

class GetUsersParams {
  final List<String> ids;

  GetUsersParams({required this.ids});
}

class GetUsersStream extends StreamUseCase<List<UserEntity>, GetUsersParams> {
  final ChatRepository repository;

  GetUsersStream({required this.repository});

  @override
  Stream<List<UserEntity>> call(GetUsersParams params) {
    return repository.getUsers(ids: params.ids);
  }
}
