import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUsecase {
  final AuthRepository repository;

  ResetPasswordUsecase({required this.repository});

  Future<void> call(String email) async {
    await repository.resetPassword(email);
  }
}
