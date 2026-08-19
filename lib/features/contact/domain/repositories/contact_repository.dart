import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';

abstract class ContactRepository {
  Future<Either<Failure, void>> addContact({required String email});
  Stream<List<UserEntity>> getContacts();
}
