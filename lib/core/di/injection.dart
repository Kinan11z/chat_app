import 'package:chat_app/features/contact/domain/usecases/add_contact_use_case.dart';
import 'package:chat_app/features/setting/domain/usecases/update_profile_use_case.dart';
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
import '../../features/contact/data/datasource/contact_remote_data_source.dart';
import '../../features/contact/data/repositories/contact_repository_imp.dart';
import '../../features/contact/domain/repositories/contact_repository.dart';
import '../../features/contact/presentation/manager/bloc/contact_bloc.dart';
import '../../features/group/data/datasource/group_remote_data_source.dart';
import '../../features/group/data/repositories/group_repository_imp.dart';
import '../../features/group/domain/repositories/group_repository.dart';
import '../../features/group/domain/usecases/create_group_use_case.dart';
import '../../features/group/domain/usecases/edit_group_use_case.dart';
import '../../features/group/domain/usecases/promote_member_use_case.dart';
import '../../features/group/domain/usecases/remove_member_use_case.dart';
import '../../features/group/domain/usecases/remove_promote_use_case.dart';
import '../../features/group/domain/usecases/send_group_image_use_case.dart';
import '../../features/group/domain/usecases/send_group_message_use_case.dart';
import '../../features/group/presentation/manager/chat_group_message/chat_group_message_bloc.dart';
import '../../features/group/presentation/manager/group/group_bloc.dart';
import '../../features/setting/data/datasource/setting_remote_data_source.dart';
import '../../features/setting/data/repositories/setting_repository_imp.dart';
import '../../features/setting/domain/repositories/settings_repository.dart';
import '../../features/setting/presentation/manager/profile/profile_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> init() async {
  //************************************* */
  // datasources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImp());
  getIt.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImp());
  getIt.registerLazySingleton<GroupRemoteDataSource>(
      () => GroupRemoteDataSourceImp());
  getIt.registerLazySingleton<ContactRemoteDataSource>(
      () => ContactRemoteDataSourceImp());
  getIt.registerLazySingleton<SettingsRemoteDataSource>(
      () => SettingsRemoteDataSourceImp());
  //************************************* */
  // repositories
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImp(remoteDataSource: getIt()));
  getIt.registerLazySingleton<GroupRepository>(
      () => GroupRepositoryImp(remoteDataSource: getIt()));
  getIt.registerLazySingleton<ContactRepository>(
      () => ContactRepositoryImp(remoteDataSource: getIt()));
  getIt.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImp(remoteDataSource: getIt()));
  //************************************* */
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
  getIt.registerLazySingleton(() => CreateGroupUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => EditGroupUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => PromoteMemberUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => RemoveMemberUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => RemovePromoteUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => SendGroupImageUseCase(repository: getIt()));
  getIt.registerLazySingleton(
      () => SendGroupMessageUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => AddContactUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => UpdateProfileUseCase(repository: getIt()));
  //************************************* */
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
  getIt.registerFactory(() => GroupBloc(
        createGroupUseCase: getIt(),
        editGroupUseCase: getIt(),
        promoteMemberUseCase: getIt(),
        removeMemberUseCase: getIt(),
        removePromoteUseCase: getIt(),
      ));
  getIt.registerFactory(() => ChatGroupMessageBloc(
        sendGroupImageUseCase: getIt(),
        sendGroupMessageUseCase: getIt(),
      ));
  getIt.registerFactory(() => ContactBloc(
        addContactUseCase: getIt(),
      ));
  getIt.registerFactory(() => ProfileBloc(
        updateProfileUseCase: getIt(),
      ));
}
