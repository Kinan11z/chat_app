import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/contact/domain/repositories/contact_repository.dart';

import '../../../../core/usecases/usecase.dart';

class GetContactsStream extends StreamUseCase<List<UserEntity>, NoParams> {
  final ContactRepository repository;

  GetContactsStream({required this.repository});

  @override
  Stream<List<UserEntity>> call(NoParams params) {
    return repository.getContacts();
  }
}