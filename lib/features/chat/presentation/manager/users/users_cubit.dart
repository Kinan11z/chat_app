import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/strings.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../domain/usecases/get_users_use_case.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final GetUsersStream getUsersStream;
  final List<String> userIds;
  late final StreamSubscription _sub;

  UsersCubit({required this.getUsersStream, required this.userIds})
      : super(UsersInitial()) {
    _sub = getUsersStream(GetUsersParams(ids: userIds)).listen(
      (users) => emit(UsersLoaded(users: users)),
      onError: (_) => emit(UsersError(message: AppStrings.somethingWentWrong)),
    );
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
