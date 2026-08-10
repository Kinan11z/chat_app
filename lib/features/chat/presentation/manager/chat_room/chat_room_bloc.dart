import 'package:bloc/bloc.dart';
import 'package:chat_app/features/chat/domain/usecases/chat_room_use_case.dart';
import 'package:meta/meta.dart';

import '../../../data/datasource/chat_remote_data_source.dart';
import '../../../data/repositories/chat_repository_imp.dart';

part 'chat_room_event.dart';
part 'chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  ChatRoomBloc() : super(ChatRoomInitial()) {
    on<CreateChatRoomEvent>(_createCharRoom);
  }
  Future<void> _createCharRoom(
      CreateChatRoomEvent event, Emitter<ChatRoomState> emit) async {
    emit(ChatRoomLoadding());
    try {
      final usecase = ChatRoomUseCase(
        repository: ChatRepositoryImp(
          remoteDataSource: ChatRemoteDataSourceImp(),
        ),
      );
      await usecase.call(event.email);
      emit(ChatRoomSuccess(message: 'Chat Created Succsfully'));
    } catch (e) {
      emit(ChatRoomError(message: e.toString()));
    }
  }
}
