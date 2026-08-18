import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/remote/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/create_user_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/update_active_use_case.dart';
import '../../features/auth/presentation/manager/auth/auth_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> init() async {
  // datasources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImp());
  // repositories
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: getIt()));
  // usecases
  getIt.registerLazySingleton(() => SignInUsecase(repository: getIt()));
  getIt.registerLazySingleton(() => SignUpUsecase(repository: getIt()));
  getIt.registerLazySingleton(() => CreateUserUsecase(repository: getIt()));
  getIt.registerLazySingleton(() => ResetPasswordUsecase(repository: getIt()));
  getIt.registerLazySingleton(() => UpdateActiveUseCase(repository: getIt()));
  // blocs
  getIt.registerLazySingleton(() => AuthBloc(
        signInUsecase: getIt(),
        signUpUsecase: getIt(),
        createUserUsecase: getIt(),
        resetPasswordUsecase: getIt(),
        updateActiveUseCase: getIt(),
      ));
}
