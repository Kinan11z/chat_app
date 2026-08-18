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
import '../../features/chat/data/datasource/chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_imp.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/chat_room_use_case.dart';
import '../../features/chat/domain/usecases/delete_message_use_case.dart';
import '../../features/chat/domain/usecases/read_message_use_case.dart';
import '../../features/chat/domain/usecases/send_image_use_case.dart';
import '../../features/chat/domain/usecases/send_message_use_case.dart';
import '../../features/chat/presentation/manager/chat_message/chat_message_bloc.dart';
import '../../features/chat/presentation/manager/chat_room/chat_room_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> init() async {
  // datasources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImp());
  getIt.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImp(remoteDataSource: getIt()));
  // repositories
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImp());
  // usecases
  getIt.registerLazySingleton(() => SignInUsecase(repository: getIt()));
  getIt.registerLazySingleton(() => SignUpUsecase(repository: getIt()));
  getIt.registerLazySingleton(() => CreateUserUsecase(repository: getIt()));
  getIt.registerLazySingleton(() => ResetPasswordUsecase(repository: getIt()));
  getIt.registerLazySingleton(() => UpdateActiveUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => ChatRoomUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => SendMessageUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => SendImageUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => ReadMessageUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => DeleteMessageUseCase(repository: getIt()));
  // blocs
  getIt.registerFactory(() => AuthBloc(
        signInUsecase: getIt(),
        signUpUsecase: getIt(),
        createUserUsecase: getIt(),
        resetPasswordUsecase: getIt(),
        updateActiveUseCase: getIt(),
      ));
  getIt.registerFactory(() => ChatMessageBloc(
        sendMessageUseCase: getIt(),
        sendImageUseCase: getIt(),
        readMessageUseCase: getIt(),
        deleteMessageUseCase: getIt(),
      ));
  getIt.registerFactory(() => ChatRoomBloc(
        chatRoomUseCase: getIt(),
      ));
}
