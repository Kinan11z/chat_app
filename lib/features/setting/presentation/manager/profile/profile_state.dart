part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

class ProfileLoadding extends ProfileState {}

final class ProfileSuccess extends ProfileState {
  final String message;

  ProfileSuccess({required this.message});
}

final class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}
