import '../../domain/repositories/contact_repository.dart';
import '../datasource/contact_remote_data_source.dart';

class ContactRepositoryImp extends ContactRepository {
  final ContactRemoteDataSource remoteDataSource;

  ContactRepositoryImp({required this.remoteDataSource});
  @override
  Future<void> addContact(String email) async {
    return await remoteDataSource.addContact(email);
  }
}
