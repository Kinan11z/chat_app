import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/strings.dart';
import '../../../domain/entities/group_message_entity.dart';
import '../../../domain/usecases/get_group_messages_use_case.dart';

part 'group_messages_state.dart';

class GroupMessagesCubit extends Cubit<GroupMessagesState> {
  final GetGroupMessagesStream getGroupMessagesStream;
  final String groupId;
  late final StreamSubscription _sub;

  GroupMessagesCubit({
    required this.getGroupMessagesStream,
    required this.groupId,
  }) : super(GroupMessagesInitial()) {
    _sub = getGroupMessagesStream(
      GetGroupMessagesParams(groupId: groupId),
    ).listen(
      (messages) {
        final sorted = List<GroupMessageEntity>.from(messages)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(GroupMessagesLoaded(messages: sorted));
      },
      onError: (_) =>
          emit(GroupMessagesError(message: AppStrings.somethingWentWrong)),
    );
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
