import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInUsecase {
  final AuthRepository repository;

  SignInUsecase({required this.repository});

  Future<User> call(String email, String password) async {
    return await repository.signIn(email, password);
  }
}
