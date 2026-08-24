import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/strings.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../domain/usecases/get_users_use_case.dart';

part 'group_members_state.dart';

class GroupMembersCubit extends Cubit<GroupMembersState> {
  final GetGroupUsersStream getGroupUsersStream;
  final List<String> memberIds;
  late final StreamSubscription _sub;

  GroupMembersCubit({
    required this.getGroupUsersStream,
    required this.memberIds,
  }) : super(GroupMembersInitial()) {
    _sub = getGroupUsersStream(GetUsersParams(ids: memberIds)).listen(
      (members) => emit(GroupMembersLoaded(members: members)),
      onError: (_) =>
          emit(GroupMembersError(message: AppStrings.somethingWentWrong)),
    );
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
