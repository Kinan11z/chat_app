import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/contact_repository.dart';
import '../datasource/contact_remote_data_source.dart';

class ContactRepositoryImp implements ContactRepository {
  final ContactRemoteDataSource remoteDataSource;

  ContactRepositoryImp({required this.remoteDataSource});
  @override
  Future<Either<Failure, void>> addContact({required String email}) async {
    try {
      await remoteDataSource.addContact(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Add contact failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<UserEntity>> getContacts() {
    return remoteDataSource.getContacts().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }
}
