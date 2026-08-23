part of 'contact_bloc.dart';

@immutable
sealed class ContactState {}

final class ContactInitial extends ContactState {}

class ContactLoadding extends ContactState {}

final class ContactSuccess extends ContactState {
  final String message;

  ContactSuccess({required this.message});
}

final class ContactError extends ContactState {
  final String message;

  ContactError({required this.message});
}
