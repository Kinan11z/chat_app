import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';

class UpdateActiveParams {
  final bool online;
  const UpdateActiveParams({required this.online});
}

class UpdateActiveUseCase extends UseCase<void, UpdateActiveParams> {
  final AuthRepository repository;

  UpdateActiveUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(UpdateActiveParams params) async {
    return await repository.updateActive(online: params.online);
  }
}
