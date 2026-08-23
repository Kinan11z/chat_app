part of 'contact_bloc.dart';

@immutable
sealed class ContactEvent {}

class AddContactEvent extends ContactEvent {
  final String email;

  AddContactEvent({required this.email});
}
