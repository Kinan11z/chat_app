import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';

class SignUpParams {
  final String email;
  final String password;
  const SignUpParams({required this.email, required this.password});
}

class SignUpUsecase extends UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpUsecase({required this.repository});

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUp(
        email: params.email, password: params.password);
  }
}
