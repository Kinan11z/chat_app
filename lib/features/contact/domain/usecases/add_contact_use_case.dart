import 'package:chat_app/core/error/failure.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/usecases/usecase.dart';
import '../repositories/contact_repository.dart';

class AddContactParams {
  final String email;

  AddContactParams({required this.email});
}

class AddContactUseCase extends UseCase<void, AddContactParams> {
  final ContactRepository repository;

  AddContactUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(AddContactParams params) async {
    return await repository.addContact(email: params.email);
  }
}
