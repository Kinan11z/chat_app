import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/strings.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/chat_group_entity.dart';
import '../../../domain/usecases/get_groups_use_case.dart';

part 'groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  final GetGroupsStream getGroupsStream;
  late final StreamSubscription _sub;

  GroupsCubit({required this.getGroupsStream}) : super(GroupsInitial()) {
    _sub = getGroupsStream(const NoParams()).listen(
      (groups) {
        final sorted = List<ChatGroupEntity>.from(groups)
          ..sort((a, b) {
            final aTime = a.lastMessageTime;
            final bTime = b.lastMessageTime;
            return bTime.compareTo(aTime);
          });
        emit(GroupsLoaded(groups: sorted));
      },
      onError: (_) => emit(GroupsError(message: AppStrings.somethingWentWrong)),
    );
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
