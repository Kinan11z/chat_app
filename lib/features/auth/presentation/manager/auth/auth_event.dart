part of 'auth_bloc.dart';

abstract class AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested({required this.email, required this.password});
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;

  SignUpRequested({required this.email, required this.password});
}

class CreateUserRequested extends AuthEvent {}

class ResetPasswordRequested extends AuthEvent {
  final String email;

  ResetPasswordRequested({required this.email});
}

class UpdateActivateEvent extends AuthEvent {
  final bool online;

  UpdateActivateEvent({required this.online});
}
