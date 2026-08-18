import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';

class SignInParams {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password});
}

class SignInUsecase extends UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;

  SignInUsecase({required this.repository});

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await repository.signIn(
        email: params.email, password: params.password);
  }
}
