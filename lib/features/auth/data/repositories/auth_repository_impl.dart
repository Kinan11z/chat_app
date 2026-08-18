import 'package:chat_app/core/error/failure.dart';
import 'package:chat_app/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signIn(
      {required String email, required String password}) async {
    try {
      final user = await remoteDataSource.signIn(email, password);
      return Right(_toEntity(user));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Sign in failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp(
      {required String email, required String password}) async {
    try {
      final user = await remoteDataSource.signUp(email, password);
      return Right(_toEntity(user));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Sign up failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await remoteDataSource.resetPassword(email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Reset password failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createUser() async {
    try {
      await remoteDataSource.createUser();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Create user failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateActive({required bool online}) async {
    try {
      await remoteDataSource.updateActive(online);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Update active failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  UserEntity _toEntity(User user) {
    return UserEntity(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      online: false,
      myUsers: [],
    );
  }
}
