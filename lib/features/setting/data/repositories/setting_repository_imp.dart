import 'dart:typed_data';

import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/setting/data/datasource/setting_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failure.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImp implements SettingsRepository {
  SettingsRemoteDataSource remoteDataSource;
  SettingsRepositoryImp({
    required this.remoteDataSource,
  });
  @override
  Future<Either<Failure, void>> updateProfileImage({
    required Uint8List imageFile,
    required String fileExtension,
  }) async {
    try {
      await remoteDataSource.updateProfileImage(
        imageFile: imageFile,
        fileExtension: fileExtension,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfileDetails({
    required String? name,
    required String? about,
    required Uint8List? imageFile,
    required String fileExtension,
  }) async {
    try {
      await remoteDataSource.updateProfileDetails(
        name: name,
        about: about,
        imageFile: imageFile,
        fileExtension: fileExtension,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePushToken({required String token}) async {
    try {
      await remoteDataSource.updatePushToken(token: token);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity> getCurrentUser() {
    return remoteDataSource.getCurrentUser().map((m) => m.toEntity());
  }
}
