import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> resetPassword({required String email});
  Future<Either<Failure, void>> updateActive({required bool online});
  Future<Either<Failure, void>> createUser();
  Stream<UserEntity?> authStateChanges();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> updateDisplayName({required String name});
}
