import 'package:chat_app/core/usecases/usecase.dart';
import 'package:chat_app/features/setting/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';

class UpdatePushTokenParams {
  final String token;

  const UpdatePushTokenParams({required this.token});
}

class UpdatePushTokenUseCase extends UseCase<void, UpdatePushTokenParams> {
  final SettingsRepository repository;

  UpdatePushTokenUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(UpdatePushTokenParams params) async {
    return await repository.updatePushToken(token: params.token);
  }
}
