import 'package:bloc/bloc.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:meta/meta.dart';

import '../../../domain/usecases/add_contact_use_case.dart';

part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final AddContactUseCase addContactUseCase;
  ContactBloc({required this.addContactUseCase}) : super(ContactInitial()) {
    on<AddContactEvent>(_addContact);
  }
  Future<void> _addContact(
      AddContactEvent event, Emitter<ContactState> emit) async {
    emit(ContactLoadding());
    final result =
        await addContactUseCase.call(AddContactParams(email: event.email));

    result.fold(
      (failure) => emit(ContactError(message: failure.message)),
      (_) => emit(ContactSuccess(message: AppStrings.addContactSuccess)),
    );
  }
}
