import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';

class ResetPasswordParams {
  final String email;
  const ResetPasswordParams({required this.email});
}

class ResetPasswordUsecase extends UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(email: params.email);
  }
}
