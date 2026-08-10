import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpUsecase {
  final AuthRepository repository;

  SignUpUsecase({required this.repository});

  Future<User> call(String email, String password) async {
    return await repository.signUp(email, password);
  }
}
