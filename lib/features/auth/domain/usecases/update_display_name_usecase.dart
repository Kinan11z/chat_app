import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class UpdateDisplayNameUseCase extends UseCase<void, UpdateDisplayNameParams> {
  final AuthRepository repository;
  UpdateDisplayNameUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(UpdateDisplayNameParams params) =>
      repository.updateDisplayName(name: params.name);
}

class UpdateDisplayNameParams {
  final String name;
  const UpdateDisplayNameParams({required this.name});
}
