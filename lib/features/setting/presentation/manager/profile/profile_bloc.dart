import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chat_app/features/setting/data/datasoure/setting_remote_data_source.dart';
import 'package:chat_app/features/setting/data/repositories/setting_repository_imp.dart';
import 'package:chat_app/features/setting/domain/usecases/update_profile_use_case.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<UpdateProfileDetails>(_updateProfileDetails);
  }
  Future<void> _updateProfileDetails(
      UpdateProfileDetails event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadding());
    try {
      final usecase = UpdateProfileUseCase(
        repository: SettingsRepositoryImp(
          remoteDataSource: SettingRemoteDataSourceImp(),
        ),
      );
      await usecase.call(
        name: event.name,
        about: event.about,
        imageFile: event.imageFile,
      );
      emit(ProfileSuccess(message: 'Add Contact Succsfully'));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
