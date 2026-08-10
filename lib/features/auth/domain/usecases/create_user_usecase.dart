import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';

class CreateUserUsecase {
  final AuthRepository repository;

  CreateUserUsecase({required this.repository});

  Future<void> call() async {
    await repository.createUser();
  }
}
