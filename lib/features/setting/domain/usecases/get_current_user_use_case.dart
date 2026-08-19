import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/setting/domain/repositories/settings_repository.dart';

import '../../../../core/usecases/usecase.dart';

class GetCurrentUserStream extends StreamUseCase<UserEntity, NoParams> {
  final SettingsRepository repository;

  GetCurrentUserStream({required this.repository});

  @override
  Stream<UserEntity> call(NoParams params) {
    return repository.getCurrentUser();
  }
}