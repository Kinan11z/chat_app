// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:chat_app/features/setting/data/datasoure/setting_remote_data_source.dart';

import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImp implements SettingsRepository {
  SettingRemoteDataSource remoteDataSource;
  SettingsRepositoryImp({
    required this.remoteDataSource,
  });
  @override
  Future<void> updateProfileImage({required File imageFile}) async {
    await remoteDataSource.updateProfileImage(imageFile: imageFile);
  }

  @override
  Future<void> updateProfileDetails({
    required String? name,
    required String? about,
    required File? imageFile,
  }) async {
    await remoteDataSource.updateProfileDetails(
      name: name,
      about: about,
      imageFile: imageFile,
    );
  }
}
