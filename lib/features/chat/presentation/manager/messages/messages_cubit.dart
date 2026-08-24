import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/strings.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/usecases/get_messages_use_case.dart';

part 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final GetMessagesStream getMessagesStream;
  final String roomId;
  late final StreamSubscription _sub;

  MessagesCubit({required this.getMessagesStream, required this.roomId})
      : super(MessagesInitial()) {
    _sub = getMessagesStream(GetMessagesParams(roomId: roomId)).listen(
      (messages) {
        final sorted = List<MessageEntity>.from(messages)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(MessagesLoaded(messages: sorted));
      },
      onError: (_) => emit(MessagesError(message: AppStrings.somethingWentWrong)),
    );
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
