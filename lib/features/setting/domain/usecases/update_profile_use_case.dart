import 'dart:typed_data';

import 'package:chat_app/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/settings_repository.dart';

class UpdateProfileParams {
  final String? name;
  final String? about;
  final Uint8List? imageFile;
  final String fileExtension;

  UpdateProfileParams({
    required this.name,
    required this.about,
    required this.imageFile,
    required this.fileExtension,
  });
}

class UpdateProfileUseCase extends UseCase<void, UpdateProfileParams> {
  final SettingsRepository repository;

  UpdateProfileUseCase({required this.repository});
  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    return await repository.updateProfileDetails(
      name: params.name,
      about: params.about,
      imageFile: params.imageFile,
      fileExtension: params.fileExtension,
    );
  }
}
