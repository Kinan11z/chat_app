import 'package:chat_app/core/error/failure.dart';
import 'package:dartz/dartz.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}

abstract class StreamUseCase<Type, Params> {
  Stream<Type> call(Params params);
}
