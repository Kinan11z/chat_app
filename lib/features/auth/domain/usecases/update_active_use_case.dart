import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';

class UpdateActiveUseCase {
  final AuthRepository repository;

  UpdateActiveUseCase({required this.repository});

  Future<void> call(bool online) async {
    return await repository.updateActive(online);
  }
}
