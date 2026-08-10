part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class UpdateProfileImage extends ProfileEvent {
  final File imageFile;

  UpdateProfileImage({required this.imageFile});
}

class UpdateProfileDetails extends ProfileEvent {
  final String? name;
  final String? about;
  final File? imageFile;

  UpdateProfileDetails({
    required this.name,
    required this.about,
    required this.imageFile,
  });
}
