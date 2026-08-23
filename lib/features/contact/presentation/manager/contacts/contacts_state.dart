part of 'contacts_cubit.dart';

sealed class ContactsState {}

final class ContactsInitial extends ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<UserEntity> contacts;
  ContactsLoaded({required this.contacts});
}

class ContactsError extends ContactsState {
  final String message;
  ContactsError({required this.message});
}
