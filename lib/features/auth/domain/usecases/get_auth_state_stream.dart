import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetAuthStateStream extends StreamUseCase<UserEntity?, NoParams> {
  final AuthRepository repository;
  GetAuthStateStream({required this.repository});

  @override
  Stream<UserEntity?> call(NoParams params) => repository.authStateChanges();
}
