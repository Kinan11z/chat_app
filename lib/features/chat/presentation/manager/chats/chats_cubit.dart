import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/strings.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/chat_room_entity.dart';
import '../../../domain/usecases/get_chats_use_case.dart';

part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  final GetChatsStream getChatsStream;
  late final StreamSubscription _sub;

  ChatsCubit({required this.getChatsStream}) : super(ChatsInitial()) {
    _sub = getChatsStream(const NoParams()).listen(
      (rooms) {
        final sorted = List<ChatRoomEntity>.from(rooms)
          ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        emit(ChatsLoaded(rooms: sorted));
      },
      onError: (_) => emit(ChatsError(message: AppStrings.somethingWentWrong)),
    );
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
