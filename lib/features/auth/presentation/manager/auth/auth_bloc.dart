import 'package:chat_app/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:chat_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chat_app/features/auth/domain/usecases/create_user_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/sign_up_usecase.dart';
import '../../../domain/usecases/update_active_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<CreateUserRequested>(_onCreateUserRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<UpdateActivateEvent>(_onUpdateActivateEvent);
  }

  Future<void> _onSignInRequested(
      SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final usecase = SignInUsecase(
        repository: AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSourceImp(),
        ),
      );
      await usecase.call(event.email, event.password);
      emit(AuthSuccess('Signed in successfully'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
      SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final usecase = SignUpUsecase(
        repository: AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSourceImp(),
        ),
      );
      await usecase.call(event.email, event.password);
      emit(AuthSuccess('Account created successfully'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCreateUserRequested(
      CreateUserRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final usecase = CreateUserUsecase(
        repository: AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSourceImp(),
        ),
      );
      await usecase.call();
      emit(AuthSuccess('Account created'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPasswordRequested(
      ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final usecase = ResetPasswordUsecase(
        repository: AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSourceImp(),
        ),
      );
      await usecase.call(event.email);
      emit(AuthSuccess('Reset email sent successfully'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onUpdateActivateEvent(
      UpdateActivateEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final usecase = UpdateActiveUseCase(
        repository: AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSourceImp(),
        ),
      );
      await usecase.call(event.online);
      emit(AuthSuccess('Activation status updated successfully'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
