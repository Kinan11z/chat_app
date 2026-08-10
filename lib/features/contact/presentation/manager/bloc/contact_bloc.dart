import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/datasource/contact_remote_data_source.dart';
import '../../../data/repositories/contact_repository_imp.dart';
import '../../../domain/usecases/add_contact_use_case.dart';

part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc() : super(ContactInitial()) {
    on<AddContactEvent>(_addContact);
  }
  Future<void> _addContact(
      AddContactEvent event, Emitter<ContactState> emit) async {
    emit(ContactLoadding());
    try {
      final usecase = AddContactUseCase(
        repository: ContactRepositoryImp(
          remoteDataSource: ContactRemoteDataSourceImp(),
        ),
      );
      await usecase.call(event.email);
      emit(ContactSuccess(message: 'Add Contact Succsfully'));
    } catch (e) {
      emit(ContactError(message: e.toString()));
    }
  }
}
