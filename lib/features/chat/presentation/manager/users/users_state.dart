part of 'users_cubit.dart';

sealed class UsersState {}

final class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<UserEntity> users;
  UsersLoaded({required this.users});
}

class UsersError extends UsersState {
  final String message;
  UsersError({required this.message});
}
