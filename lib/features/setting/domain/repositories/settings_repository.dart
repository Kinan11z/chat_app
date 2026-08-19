import 'dart:typed_data';

import 'package:chat_app/core/error/failure.dart';
import 'package:dartz/dartz.dart';

abstract class SettingsRepository {
  Future<Either<Failure, void>> updateProfileImage({
    required Uint8List imageFile,
    required String fileExtension,
  });
  Future<Either<Failure, void>> updateProfileDetails({
    required String? name,
    required String? about,
    required Uint8List? imageFile,
    required String fileExtension,
  });
}
