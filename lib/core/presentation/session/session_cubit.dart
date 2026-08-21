import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/domain/entities/user_entity.dart';
import '../../../features/auth/domain/usecases/get_auth_state_stream.dart';
import '../../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../../features/auth/domain/usecases/update_active_use_case.dart';
import '../../../features/setting/domain/usecases/get_current_user_use_case.dart';
import '../../usecases/usecase.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final GetAuthStateStream getAuthStateStream;
  final GetCurrentUserStream getCurrentUserStream;
  final UpdateActiveUseCase updateActiveUseCase;
  final SignOutUseCase signOutUseCase;
  late final StreamSubscription _authSub;
  StreamSubscription? _userSub;

  SessionCubit({
    required this.getAuthStateStream,
    required this.getCurrentUserStream,
    required this.updateActiveUseCase,
    required this.signOutUseCase,
  }) : super(const SessionState(status: SessionStatus.unknown)) {
    _authSub = getAuthStateStream(const NoParams()).listen(_onAuthChanged);
  }
  @override
  Future<void> close() {
    _authSub.cancel();
    _userSub?.cancel();
    return super.close();
  }

  void _onAuthChanged(UserEntity? authUser) {
    _userSub?.cancel();
    if (authUser == null) {
      emit(const SessionState(status: SessionStatus.unauthenticated));
      return;
    }
    _userSub = getCurrentUserStream(const NoParams()).listen(
      (profile) {
        emit(SessionState(
          status: profile.name.isEmpty
              ? SessionStatus.newUser
              : SessionStatus.authenticated,
          user: profile,
        ));
      },
      onError: (_) => emit(const SessionState(status: SessionStatus.unknown)),
    );
  }

  void setOnline(bool online) {
    updateActiveUseCase(UpdateActiveParams(online: online));
  }

  Future<void> signOut() async {
    await signOutUseCase(const NoParams());
  }
}
