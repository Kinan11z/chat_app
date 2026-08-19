part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class UpdateProfileDetails extends ProfileEvent {
  final String? name;
  final String? about;
  final Uint8List? imageFile;
  final String fileExtension;

  UpdateProfileDetails({
    required this.name,
    required this.about,
    required this.imageFile,
    required this.fileExtension,
  });
}
