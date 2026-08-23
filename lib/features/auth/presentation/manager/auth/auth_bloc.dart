import 'package:chat_app/features/auth/domain/usecases/create_user_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/strings.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/sign_up_usecase.dart';
import '../../../domain/usecases/update_active_use_case.dart';
import '../../../domain/usecases/update_display_name_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUsecase signInUsecase;
  final SignUpUsecase signUpUsecase;
  final CreateUserUsecase createUserUsecase;
  final ResetPasswordUsecase resetPasswordUsecase;
  final UpdateActiveUseCase updateActiveUseCase;
  final UpdateDisplayNameUseCase updateDisplayNameUseCase;
  AuthBloc({
    required this.signInUsecase,
    required this.signUpUsecase,
    required this.createUserUsecase,
    required this.resetPasswordUsecase,
    required this.updateActiveUseCase,
    required this.updateDisplayNameUseCase,
  }) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<CreateUserRequested>(_onCreateUserRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<UpdateActivateEvent>(_onUpdateActivateEvent);
  }

  Future<void> _onSignInRequested(
      SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signInUsecase(
        SignInParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthSuccess(AppStrings.signedInSuccess)),
    );
  }

  Future<void> _onSignUpRequested(
      SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signUpUsecase(
        SignUpParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthSuccess(AppStrings.signUpSuccess)),
    );
  }

  Future<void> _onCreateUserRequested(
      CreateUserRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final nameResult = await updateDisplayNameUseCase(
        UpdateDisplayNameParams(name: event.name));
    if (nameResult.isLeft()) {
      emit(AuthError(nameResult.fold((f) => f.message, (_) => '')));
      return;
    }
    final result = await createUserUsecase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthSuccess(AppStrings.accountCreatedSuccess)),
    );
  }

  Future<void> _onResetPasswordRequested(
      ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result =
        await resetPasswordUsecase(ResetPasswordParams(email: event.email));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthSuccess(AppStrings.resetSentSuccess)),
    );
  }

  Future<void> _onUpdateActivateEvent(
      UpdateActivateEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result =
        await updateActiveUseCase(UpdateActiveParams(online: event.online));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthSuccess(AppStrings.activationUpdatedSuccess)),
    );
  }
}
