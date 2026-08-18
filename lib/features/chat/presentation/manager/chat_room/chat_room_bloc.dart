import 'package:bloc/bloc.dart';
import 'package:chat_app/features/chat/domain/usecases/chat_room_use_case.dart';
import 'package:meta/meta.dart';

import '../../../../../core/constants/strings.dart';

part 'chat_room_event.dart';
part 'chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final ChatRoomUseCase chatRoomUseCase;
  ChatRoomBloc({required this.chatRoomUseCase}) : super(ChatRoomInitial()) {
    on<CreateChatRoomEvent>(_createCharRoom);
  }
  Future<void> _createCharRoom(
      CreateChatRoomEvent event, Emitter<ChatRoomState> emit) async {
    emit(ChatRoomLoadding());
    final result =
        await chatRoomUseCase(CreateChatRoomParams(email: event.email));
    result.fold(
      (failure) => emit(ChatRoomError(message: failure.message)),
      (_) => emit(ChatRoomSuccess(message: AppStrings.chatCreatedSuccess)),
    );
  }
}
