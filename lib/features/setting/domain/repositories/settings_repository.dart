import 'dart:io';

abstract class SettingsRepository {
  Future<void> updateProfileImage({
    required File imageFile,
  });
  Future<void> updateProfileDetails({
    required String? name,
    required String? about,
    required File? imageFile,
  });
}
