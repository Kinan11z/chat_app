import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:chat_app/core/constants/strings.dart';

import 'package:chat_app/features/setting/domain/usecases/update_profile_use_case.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateProfileUseCase updateProfileUseCase;
  ProfileBloc({required this.updateProfileUseCase}) : super(ProfileInitial()) {
    on<UpdateProfileDetails>(_updateProfileDetails);
  }
  Future<void> _updateProfileDetails(
      UpdateProfileDetails event, Emitter<ProfileState> emit) async {
    emit(ProfileLoadding());
    final result = await updateProfileUseCase.call(
      UpdateProfileParams(
        name: event.name,
        about: event.about,
        imageFile: event.imageFile,
        fileExtension: event.fileExtension,
      ),
    );
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(
        ProfileSuccess(
          message: AppStrings.profileUpdatedSuccess,
        ),
      ),
    );
  }
}
