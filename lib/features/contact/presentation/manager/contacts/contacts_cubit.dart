import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/strings.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../domain/usecases/get_contacts_use_case.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final GetContactsStream getContactsStream;
  late final StreamSubscription _sub;

  ContactsCubit({required this.getContactsStream}) : super(ContactsInitial()) {
    _sub = getContactsStream(const NoParams()).listen(
      (contacts) {
        final sorted = List<UserEntity>.from(contacts)
          ..sort((a, b) => a.name.compareTo(b.name));
        emit(ContactsLoaded(contacts: sorted));
      },
      onError: (_) =>
          emit(ContactsError(message: AppStrings.somethingWentWrong)),
    );
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
