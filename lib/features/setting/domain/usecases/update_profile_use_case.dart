import 'dart:io';

import '../repositories/settings_repository.dart';

class UpdateProfileUseCase {
  final SettingsRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<void> call({
    required String? name,
    required String? about,
    required File? imageFile,
  }) async {
    await repository.updateProfileDetails(
      name: name,
      about: about,
      imageFile: imageFile,
    );
  }
}
